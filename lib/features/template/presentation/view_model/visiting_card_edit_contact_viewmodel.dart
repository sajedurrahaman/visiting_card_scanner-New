import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/app/storage/app_storage_service.dart';
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/domain/model/saved_file_model.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/scan/domain/saved_contact_info.dart';
import 'package:visiting_card/features/template/domain/visiting_card_field_transform.dart';
import 'package:visiting_card/features/template/domain/visiting_card_font_style.dart';
import 'package:visiting_card/features/template/domain/visiting_card_position_config.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_template_viewmodel.dart';

class ContactFieldEntry {
  ContactFieldEntry({
    this.value = '',
    this.type = '',
  });

  String value;
  String type;
}

/// Required fields validated on Edit Contact Info → Next.
enum ContactValidationField {
  name,
  designation,
  company,
  phone,
  email,
  address,
}

class VisitingCardEditContactViewModel extends ChangeNotifier {
  VisitingCardEditContactViewModel({
    required this.templateId,
    required this.isHorizontal,
    required this.frontAssetWithoutData,
    required this.backAssetWithoutData,
  });

  factory VisitingCardEditContactViewModel.fromTemplate(
    VisitingCardTemplateItem item, {
    required bool isHorizontal,
  }) {
    return VisitingCardEditContactViewModel(
      templateId: item.id,
      isHorizontal: isHorizontal,
      frontAssetWithoutData: item.frontAssetWithoutData,
      backAssetWithoutData: item.backAssetWithoutData,
    );
  }

  String templateId;
  bool isHorizontal;
  String frontAssetWithoutData;
  String backAssetWithoutData;

  final ScreenshotController screenshotController = ScreenshotController();

  /// When editing an existing saved template card (details → Edit).
  String? editingSavedFileId;
  String? editingContactFolderPath;
  String? editingFolderId;
  String? editingDateTime;

  bool get isUpdatingExisting =>
      editingSavedFileId != null &&
      editingContactFolderPath != null &&
      editingContactFolderPath!.isNotEmpty;

  static const telTypes = [
    'Tel',
    'Fax',
    'Cell',
    'Home',
    'Work',
    'Desk',
    'Others',
  ];
  static const emailWebsiteTypes = ['Company', 'Personal'];

  int sideIndex = 0;
  bool isSaving = false;

  String? qrAssetPath = ui.AppAssets.defaultQrcodeIcon;
  String? logoAssetPath;
  bool hasChosenQr = false;
  bool hasChosenLogo = false;

  /// Runtime finger placement overrides (merged over template defaults).
  final Map<String, VisitingCardFieldTransform> frontOverlays = {};
  final Map<String, VisitingCardFieldTransform> backOverlays = {};
  VisitingCardOverlayField? selectedOverlay;

  /// Id of a Duplicate copy when that copy is selected.
  String? selectedDuplicateId;

  /// True while user is dragging / resizing a field overlay (skip scroll toast).
  bool overlayGestureActive = false;

  /// Download/save capture jumps to the side instead of animating the pager,
  /// so the PNG is not a mid-swipe mix of the front and back.
  bool jumpSideForCapture = false;

  final List<_CardEditSnapshot> _undoStack = [];
  final List<_CardEditSnapshot> _redoStack = [];
  _CardEditSnapshot? _historyPoint;
  DateTime? _historyAt;
  bool _historyReady = false;
  bool _restoringHistory = false;
  static const _historyLimit = 40;

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  /// Starts a fresh history from the card as it is now.
  void beginUndoHistory() {
    _undoStack.clear();
    _redoStack.clear();
    _historyAt = null;
    _historyReady = true;
    _historyPoint = _captureEditSnapshot();
    notifyListeners();
  }

  void undo() {
    if (_undoStack.isEmpty || _historyPoint == null) return;
    _redoStack.add(_historyPoint!);
    _applyEditSnapshot(_undoStack.removeLast());
  }

  void redo() {
    if (_redoStack.isEmpty || _historyPoint == null) return;
    _undoStack.add(_historyPoint!);
    _applyEditSnapshot(_redoStack.removeLast());
  }

  @override
  void notifyListeners() {
    _recordEditHistory();
    super.notifyListeners();
  }

  final List<ContactFieldEntry> names = [ContactFieldEntry()];
  final List<ContactFieldEntry> designations = [ContactFieldEntry()];
  final List<ContactFieldEntry> companies = [ContactFieldEntry()];
  final List<ContactFieldEntry> taglines = [ContactFieldEntry()];
  final List<ContactFieldEntry> phones = [
    ContactFieldEntry(type: 'Cell'),
  ];
  final List<ContactFieldEntry> emails = [
    ContactFieldEntry(type: 'Company'),
  ];
  final List<ContactFieldEntry> websites = [
    ContactFieldEntry(type: 'Company'),
  ];
  final List<ContactFieldEntry> addresses = [ContactFieldEntry()];

  bool get isFront => sideIndex == 0;
  bool get isBack => sideIndex == 1;

  /// Horizontal 2–8, 10–11, 14, 17–18 + vertical 1, 2, 4–10 have logo on the front.
  bool get hasFrontLogo {
    const frontLogoIds = {
      'h2',
      'h3',
      'h4',
      'h5',
      'h6',
      'h7',
      'h8',
      'h10',
      'h11',
      'h14',
      'h17',
      'h18',
      'v1',
      'v2',
      'v4',
      'v5',
      'v6',
      'v7',
      'v8',
      'v9',
      'v10',
    };
    return frontLogoIds.contains(templateId);
  }

  /// Front QR: horizontal 11, 12, 18, 19.
  bool get hasFrontQr {
    const frontQrIds = {'h11', 'h12', 'h18', 'h19'};
    return frontQrIds.contains(templateId);
  }

  /// Templates without any QR on either side.
  bool get hasQr {
    const noQrIds = {'h13', 'h14', 'h15', 'h16', 'h17', 'h20'};
    return !noQrIds.contains(templateId);
  }

  bool get canEditQr {
    if (!hasQr) return false;
    return isBack || (isFront && hasFrontQr);
  }

  /// Logo: back always; front only for templates that have front logo.
  bool get canEditLogo => isBack || (isFront && hasFrontLogo);

  String get currentBackgroundAsset =>
      isFront ? frontAssetWithoutData : backAssetWithoutData;

  String get displayName =>
      names.isNotEmpty ? names.first.value.trim() : '';
  String get displayDesignation =>
      designations.isNotEmpty ? designations.first.value.trim() : '';
  String get displayCompany =>
      companies.isNotEmpty ? companies.first.value.trim() : '';
  String get displayTagline =>
      taglines.isNotEmpty ? taglines.first.value.trim() : '';
  String get displayAddress =>
      addresses.isNotEmpty ? addresses.first.value.trim() : '';

  /// Template front-name cap from [VisitingCardFieldPosition.maxDisplayNameLength].
  int get maxDisplayNameLength {
    final layout = VisitingCardPositionConfig.forTemplate(
      templateId: templateId,
      isHorizontal: isHorizontal,
    );
    final max = layout.front.name?.maxDisplayNameLength ?? 16;
    return max < 1 ? 1 : max;
  }

  /// Fields that failed the last [validateRequiredContactFields] pass.
  final Set<ContactValidationField> invalidFields = {};

  bool isFieldInvalid(ContactValidationField field) =>
      invalidFields.contains(field);

  void clearFieldError(ContactValidationField field) {
    if (invalidFields.remove(field)) notifyListeners();
  }

  /// Returns first validation error for required contact fields, or `null`.
  /// Marks all failing fields in [invalidFields] (red underline in UI).
  /// Validates: Name, Designation, Company, Tell, Email, Address.
  String? validateRequiredContactFields() {
    invalidFields.clear();
    String? firstError;

    void fail(ContactValidationField field, String message) {
      invalidFields.add(field);
      firstError ??= message;
    }

    if (displayName.isEmpty) {
      fail(ContactValidationField.name, 'Please enter name');
    } else if (displayName.length > maxDisplayNameLength) {
      fail(
        ContactValidationField.name,
        'Name length max-$maxDisplayNameLength',
      );
    }
    if (displayDesignation.isEmpty) {
      fail(ContactValidationField.designation, 'Please enter designation');
    }
    if (displayCompany.isEmpty) {
      fail(ContactValidationField.company, 'Please enter company');
    }

    final phone = phones
        .map((e) => e.value.trim())
        .firstWhere((v) => v.isNotEmpty, orElse: () => '');
    if (phone.isEmpty) {
      fail(ContactValidationField.phone, 'Please enter phone number');
    } else {
      final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
      final digitOnly = digits.replaceAll('+', '');
      if (digitOnly.isEmpty || !RegExp(r'^\d+$').hasMatch(digitOnly)) {
        fail(
          ContactValidationField.phone,
          'Please enter a valid phone number',
        );
      } else if (digitOnly.length < 5 || digitOnly.length > 15) {
        fail(
          ContactValidationField.phone,
          'Phone number length min-5 and max-15',
        );
      }
    }

    final email = emails
        .map((e) => e.value.trim())
        .firstWhere((v) => v.isNotEmpty, orElse: () => '');
    if (email.isEmpty) {
      fail(ContactValidationField.email, 'Please enter email');
    } else {
      final emailOk =
          RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
      if (!emailOk) {
        fail(
          ContactValidationField.email,
          'Please enter a valid email address',
        );
      }
    }

    if (displayAddress.isEmpty) {
      fail(ContactValidationField.address, 'Please enter address');
    }

    notifyListeners();
    return firstError;
  }

  void setSide(int index) {
    if (index < 0 || index > 1) return;
    final changed = index != sideIndex;
    if (!changed && !jumpSideForCapture) return;
    sideIndex = index;
    if (changed) {
      selectedOverlay = null;
      selectedDuplicateId = null;
    }
    notifyListeners();
  }

  void showFront() => setSide(0);
  void showBack() => setSide(1);

  Map<String, VisitingCardFieldTransform> get currentOverlays =>
      isFront ? frontOverlays : backOverlays;

  VisitingCardFieldTransforms get fieldTransformsSnapshot =>
      VisitingCardFieldTransforms(
        front: Map<String, VisitingCardFieldTransform>.from(frontOverlays),
        back: Map<String, VisitingCardFieldTransform>.from(backOverlays),
      );

  void applyFieldTransforms(VisitingCardFieldTransforms transforms) {
    frontOverlays
      ..clear()
      ..addAll(transforms.front);
    backOverlays
      ..clear()
      ..addAll(transforms.back);
    selectedOverlay = null;
    selectedDuplicateId = null;
    notifyListeners();
  }

  VisitingCardFieldTransform? overlayFor(
    VisitingCardOverlayField field, {
    bool? isFront,
  }) {
    final map = (isFront ?? this.isFront) ? frontOverlays : backOverlays;
    return map[VisitingCardFieldTransform.keyOf(field)];
  }

  /// Default transform from template position config for [field] on a side.
  VisitingCardFieldTransform? defaultTransformFor(
    VisitingCardOverlayField field, {
    bool? isFront,
  }) {
    final useFront = isFront ?? this.isFront;
    final layout = VisitingCardPositionConfig.forTemplate(
      templateId: templateId,
      isHorizontal: isHorizontal,
    );
    final side = useFront ? layout.front : layout.back;
    final pos = switch (field) {
      VisitingCardOverlayField.name => side.name,
      VisitingCardOverlayField.designation => side.designation,
      VisitingCardOverlayField.company => side.company,
      VisitingCardOverlayField.tagline => side.tagline,
      VisitingCardOverlayField.phone => side.phone,
      VisitingCardOverlayField.email => side.email,
      VisitingCardOverlayField.website => side.website,
      VisitingCardOverlayField.address => side.address,
      VisitingCardOverlayField.logo => side.logo,
      VisitingCardOverlayField.qr => side.qr,
    };
    if (pos == null) return null;
    final left = pos.left ?? 0;
    final top = pos.top ??
        (pos.bottom != null ? (1.0 - (pos.bottom! + (pos.size ?? 0.14))) : 0.0);
    final double size;
    if (field.isImageOverlay) {
      size = pos.size ?? 0.14;
    } else if (field == VisitingCardOverlayField.name) {
      // Keep 3-word compact size when selecting (don't jump to full fontSize).
      size = pos.resolvedNameFontSize(displayName);
    } else {
      size = pos.fontSize;
    }
    return VisitingCardFieldTransform(
      left: left,
      top: top.clamp(0.0, 1.0),
      size: size,
      // Text width stays free until the user stretches the selection;
      // template `pos.width` is applied only at layout time for portrait.
      width: field.isImageOverlay ? pos.width : null,
    );
  }

  VisitingCardFieldTransform resolvedTransform(
    VisitingCardOverlayField field, {
    bool? isFront,
  }) {
    return overlayFor(field, isFront: isFront) ??
        defaultTransformFor(field, isFront: isFront) ??
        const VisitingCardFieldTransform(left: 0.4, top: 0.1, size: 0.14);
  }

  bool get hasSelection =>
      selectedOverlay != null || selectedDuplicateId != null;

  static String duplicateKey(String id) => 'dup:$id';

  /// Free text added from the landscape Text tool. Not a template field.
  static const customTextSource = 'custom';

  /// Icon added from the landscape Icon picker. Not a template field.
  static const customIconSource = 'icon';

  /// Shape added from the landscape Shape picker. Not a template field.
  static const customShapeSource = 'shape';

  /// Photo added from the landscape Images tool. Not a template field.
  static const customImageSource = 'image';

  bool _sourceIsImage(String? source) =>
      source == 'logo' ||
      source == 'qr' ||
      source == customIconSource ||
      source == customShapeSource ||
      source == customImageSource;

  bool get selectedIsShape {
    if (selectedDuplicateId == null) return false;
    return currentOverlays[duplicateKey(selectedDuplicateId!)]?.duplicateOf ==
        customShapeSource;
  }

  /// Template logo field, or an extra logo added from the Logos tool.
  bool get selectedIsLogo {
    if (selectedDuplicateId != null) {
      return currentOverlays[duplicateKey(selectedDuplicateId!)]?.duplicateOf ==
          'logo';
    }
    return selectedOverlay == VisitingCardOverlayField.logo;
  }

  bool get selectedIsImage {
    if (selectedDuplicateId != null) {
      return _sourceIsImage(
        currentOverlays[duplicateKey(selectedDuplicateId!)]?.duplicateOf,
      );
    }
    return selectedOverlay?.isImageOverlay ?? false;
  }

  VisitingCardFieldTransform? get activeTransform {
    if (selectedDuplicateId != null) {
      return currentOverlays[duplicateKey(selectedDuplicateId!)];
    }
    final field = selectedOverlay;
    if (field == null) return null;
    return resolvedTransform(field);
  }

  void _putActive(VisitingCardFieldTransform next) {
    if (selectedDuplicateId != null) {
      currentOverlays[duplicateKey(selectedDuplicateId!)] = next;
    } else if (selectedOverlay != null) {
      _ensureOverlay(selectedOverlay!);
      currentOverlays[VisitingCardFieldTransform.keyOf(selectedOverlay!)] =
          next;
    }
    notifyListeners();
  }

  void selectOverlay(VisitingCardOverlayField field) {
    FocusManager.instance.primaryFocus?.unfocus();
    _ensureOverlay(field);
    selectedOverlay = field;
    selectedDuplicateId = null;
    // Writing the default layout is not an edit, so Undo stays off.
    _absorbUnchangedEdit();
    notifyListeners();
  }

  void selectDuplicate(String id) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (currentOverlays[duplicateKey(id)] == null) return;
    selectedOverlay = null;
    selectedDuplicateId = id;
    notifyListeners();
  }

  void clearOverlaySelection() {
    if (selectedOverlay == null && selectedDuplicateId == null) return;
    selectedOverlay = null;
    selectedDuplicateId = null;
    overlayGestureActive = false;
    notifyListeners();
  }

  /// Swaps the card design. Contact text stays; field positions reset
  /// so the new template's layout is used.
  void applyTemplate(
    VisitingCardTemplateItem item, {
    required bool horizontal,
  }) {
    if (templateId == item.id && isHorizontal == horizontal) return;
    templateId = item.id;
    isHorizontal = horizontal;
    frontAssetWithoutData = item.frontAssetWithoutData;
    backAssetWithoutData = item.backAssetWithoutData;
    frontOverlays.clear();
    backOverlays.clear();
    selectedOverlay = null;
    selectedDuplicateId = null;
    overlayGestureActive = false;
    sideIndex = 0;
    notifyListeners();
  }

  /// Places a scanner icon on the current side and selects it.
  void addCustomIcon(String assetPath) {
    final path = assetPath.trim();
    if (path.isEmpty) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final existing = currentOverlays.values
        .where((t) => t.duplicateOf == customIconSource)
        .length;
    final nudge = (existing % 6) * 0.04;
    currentOverlays[duplicateKey(id)] = VisitingCardFieldTransform(
      left: (0.42 + nudge).clamp(0.06, 0.78),
      top: (0.34 + nudge).clamp(0.06, 0.78),
      size: 0.10,
      duplicateOf: customIconSource,
      duplicateImagePath: path,
    );
    selectedOverlay = null;
    selectedDuplicateId = id;
    notifyListeners();
  }

  /// Places a scanner shape on the current side and selects it.
  void addCustomShape(String assetPath) {
    final path = assetPath.trim();
    if (path.isEmpty) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final existing = currentOverlays.values
        .where((t) => t.duplicateOf == customShapeSource)
        .length;
    final nudge = (existing % 6) * 0.04;
    currentOverlays[duplicateKey(id)] = VisitingCardFieldTransform(
      left: (0.38 + nudge).clamp(0.06, 0.78),
      top: (0.30 + nudge).clamp(0.06, 0.78),
      size: 0.10,
      duplicateOf: customShapeSource,
      duplicateImagePath: path,
    );
    selectedOverlay = null;
    selectedDuplicateId = id;
    notifyListeners();
  }

  /// Adds another logo on the current side. The logo already on the card stays.
  void addCustomLogo(String assetPath) {
    final path = assetPath.trim();
    if (path.isEmpty) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final existing = currentOverlays.values
        .where((t) => t.duplicateOf == 'logo')
        .length;
    final nudge = (existing % 6) * 0.05;
    currentOverlays[duplicateKey(id)] = VisitingCardFieldTransform(
      left: (0.58 + nudge).clamp(0.06, 0.78),
      top: (0.12 + nudge).clamp(0.06, 0.72),
      size: 0.14,
      duplicateOf: 'logo',
      duplicateImagePath: path,
    );
    selectedOverlay = null;
    selectedDuplicateId = id;
    notifyListeners();
  }

  /// Places a gallery photo on the current side and selects it.
  void addCustomImage(String filePath) {
    final path = filePath.trim();
    if (path.isEmpty) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final existing = currentOverlays.values
        .where((t) => t.duplicateOf == customImageSource)
        .length;
    final nudge = (existing % 6) * 0.04;
    currentOverlays[duplicateKey(id)] = VisitingCardFieldTransform(
      left: (0.28 + nudge).clamp(0.06, 0.62),
      top: (0.22 + nudge).clamp(0.06, 0.62),
      size: 0.32,
      duplicateOf: customImageSource,
      duplicateImagePath: path,
    );
    selectedOverlay = null;
    selectedDuplicateId = id;
    notifyListeners();
  }

  /// Replaces the selected logo, or adds a new one when no logo is selected.
  void placeLogo(String path) {
    final value = path.trim();
    if (value.isEmpty) return;
    if (!selectedIsLogo) {
      addCustomLogo(value);
      return;
    }
    if (selectedDuplicateId != null) {
      final key = duplicateKey(selectedDuplicateId!);
      final current = currentOverlays[key];
      if (current != null) {
        currentOverlays[key] = current.copyWith(duplicateImagePath: value);
        notifyListeners();
      }
      return;
    }
    applyLogoImage(value);
  }

  /// Adds a new text field on the current side and selects it.
  void addCustomText(String text) {
    final value = text.trim();
    if (value.isEmpty) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final existing = currentOverlays.values
        .where((t) => t.duplicateOf == customTextSource)
        .length;
    final nudge = (existing % 6) * 0.035;
    currentOverlays[duplicateKey(id)] = VisitingCardFieldTransform(
      left: (0.30 + nudge).clamp(0.06, 0.72),
      top: (0.36 + nudge).clamp(0.06, 0.78),
      size: 14,
      duplicateOf: customTextSource,
      duplicateText: value,
    );
    selectedOverlay = null;
    selectedDuplicateId = id;
    notifyListeners();
  }

  /// Copies the selected field slightly down and to the right, then selects it.
  void duplicateSelectedOverlay() {
    final current = activeTransform;
    if (current == null) return;
    final sourceName = current.duplicateOf ?? selectedOverlay?.name;
    if (sourceName == null) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final text = current.duplicateText ??
        (selectedOverlay == null ? '' : overlayText(selectedOverlay!));
    final image = current.duplicateImagePath ??
        (sourceName == 'logo'
            ? logoAssetPath
            : sourceName == 'qr'
                ? qrAssetPath
                : null);
    currentOverlays[duplicateKey(id)] = current.copyWith(
      left: (current.left + 0.04).clamp(-0.2, 0.9),
      top: (current.top + 0.06).clamp(-0.2, 0.9),
      duplicateOf: sourceName,
      duplicateText: text,
      duplicateImagePath: image,
    );
    selectedOverlay = null;
    selectedDuplicateId = id;
    notifyListeners();
  }

  /// Removes the selected field from the card and clears the selection.
  void deleteSelectedOverlay() {
    if (selectedDuplicateId != null) {
      currentOverlays.remove(duplicateKey(selectedDuplicateId!));
      selectedDuplicateId = null;
      overlayGestureActive = false;
      notifyListeners();
      return;
    }
    final field = selectedOverlay;
    if (field == null) return;
    switch (field) {
      case VisitingCardOverlayField.logo:
        hasChosenLogo = false;
        logoAssetPath = null;
      case VisitingCardOverlayField.qr:
        hasChosenQr = false;
        qrAssetPath = null;
      default:
        setOverlayText(field, '');
    }
    currentOverlays.remove(VisitingCardFieldTransform.keyOf(field));
    selectedOverlay = null;
    overlayGestureActive = false;
    notifyListeners();
  }

  void beginOverlayGesture() {
    if (overlayGestureActive) return;
    overlayGestureActive = true;
  }

  void endOverlayGesture() {
    if (!overlayGestureActive) return;
    overlayGestureActive = false;
    notifyListeners();
  }

  void _ensureOverlay(VisitingCardOverlayField field) {
    final key = VisitingCardFieldTransform.keyOf(field);
    currentOverlays.putIfAbsent(
      key,
      () => resolvedTransform(field),
    );
  }

  void moveOverlay(
    VisitingCardOverlayField field,
    double pixelDx,
    double pixelDy,
    Size cardSize, {
    String? duplicateId,
  }) {
    if (cardSize.width <= 0 || cardSize.height <= 0) return;
    final key = duplicateId == null
        ? VisitingCardFieldTransform.keyOf(field)
        : duplicateKey(duplicateId);
    if (duplicateId == null) _ensureOverlay(field);
    final current = currentOverlays[key];
    if (current == null) return;
    currentOverlays[key] = current.copyWith(
      left: (current.left + pixelDx / cardSize.width).clamp(-0.2, 0.95),
      top: (current.top + pixelDy / cardSize.height).clamp(-0.2, 0.95),
    );
    notifyListeners();
  }

  /// Landscape arrow pad: nudge the selected field by a fraction of the card.
  void nudgeSelectedOverlay(double dxFraction, double dyFraction) {
    final current = activeTransform;
    if (current == null) return;
    _putActive(
      current.copyWith(
        left: (current.left + dxFraction).clamp(-0.2, 0.95),
        top: (current.top + dyFraction).clamp(-0.2, 0.95),
      ),
    );
  }

  /// Text currently on the selected field, including a duplicate copy.
  String get selectedOverlaySample {
    if (selectedDuplicateId != null) {
      final copy =
          currentOverlays[duplicateKey(selectedDuplicateId!)]?.duplicateText;
      if (copy != null && copy.trim().isNotEmpty) return copy.trim();
    }
    final field = selectedOverlay ?? _fontSourceField;
    if (field == null || field.isImageOverlay) return '';
    return overlayText(field).trim();
  }

  String overlayText(VisitingCardOverlayField field) {
    return switch (field) {
      VisitingCardOverlayField.name => displayName,
      VisitingCardOverlayField.designation => displayDesignation,
      VisitingCardOverlayField.company => displayCompany,
      VisitingCardOverlayField.tagline => displayTagline,
      VisitingCardOverlayField.phone =>
        phones.isEmpty ? '' : phones.first.value,
      VisitingCardOverlayField.email =>
        emails.isEmpty ? '' : emails.first.value,
      VisitingCardOverlayField.website =>
        websites.isEmpty ? '' : websites.first.value,
      VisitingCardOverlayField.address => displayAddress,
      VisitingCardOverlayField.logo || VisitingCardOverlayField.qr => '',
    };
  }

  void setOverlayText(VisitingCardOverlayField field, String value) {
    if (selectedDuplicateId != null && selectedOverlay == null) {
      final current = currentOverlays[duplicateKey(selectedDuplicateId!)];
      if (current == null) return;
      currentOverlays[duplicateKey(selectedDuplicateId!)] =
          current.copyWith(duplicateText: value);
      notifyListeners();
      return;
    }
    switch (field) {
      case VisitingCardOverlayField.name:
        updateSimpleField(names, 0, value);
      case VisitingCardOverlayField.designation:
        updateSimpleField(designations, 0, value);
      case VisitingCardOverlayField.company:
        updateSimpleField(companies, 0, value);
      case VisitingCardOverlayField.tagline:
        updateSimpleField(taglines, 0, value);
      case VisitingCardOverlayField.phone:
        updateTypedField(phones, 0, value: value);
      case VisitingCardOverlayField.email:
        updateTypedField(emails, 0, value: value);
      case VisitingCardOverlayField.website:
        updateTypedField(websites, 0, value: value);
      case VisitingCardOverlayField.address:
        updateSimpleField(addresses, 0, value);
      case VisitingCardOverlayField.logo:
      case VisitingCardOverlayField.qr:
        break;
    }
  }

  void resizeOverlay(
    VisitingCardOverlayField field,
    double pixelDeltaY,
    Size cardSize, {
    String? duplicateId,
  }) {
    if (cardSize.width <= 0) return;
    final key = duplicateId == null
        ? VisitingCardFieldTransform.keyOf(field)
        : duplicateKey(duplicateId);
    if (duplicateId == null) _ensureOverlay(field);
    final current = currentOverlays[key];
    if (current == null) return;
    final isImage = duplicateId == null
        ? field.isImageOverlay
        : _sourceIsImage(current.duplicateOf);
    final next = isImage
        ? (current.size + pixelDeltaY / cardSize.width).clamp(0.06, 0.55)
        : (current.size + pixelDeltaY * 0.08).clamp(4.0, 28.0);
    currentOverlays[key] = current.copyWith(size: next);
    notifyListeners();
  }

  bool get selectedIsLocked => activeTransform?.locked ?? false;

  /// Puts the selected field behind every other field, including text.
  void sendSelectedOverlayBack() => _moveSelectedStack(toFront: false);

  /// Puts the selected field in front of every other field.
  void sendSelectedOverlayFront() => _moveSelectedStack(toFront: true);

  /// Fields currently painted on this side, back to front.
  List<String> _visibleStackKeys() {
    final keys = <String>[];
    for (final field in VisitingCardOverlayField.values) {
      if (field.isImageOverlay) {
        final shown = field == VisitingCardOverlayField.logo
            ? hasChosenLogo
            : hasChosenQr;
        if (shown) keys.add(VisitingCardFieldTransform.keyOf(field));
      } else if (overlayText(field).trim().isNotEmpty) {
        keys.add(VisitingCardFieldTransform.keyOf(field));
      }
    }
    for (final entry in currentOverlays.entries) {
      if (!entry.key.startsWith('dup:')) continue;
      final text = entry.value.duplicateText?.trim() ?? '';
      final image = entry.value.duplicateImagePath ?? '';
      if (text.isNotEmpty || image.isNotEmpty) keys.add(entry.key);
    }
    final dupOrder = [
      for (final key in currentOverlays.keys)
        if (key.startsWith('dup:')) key,
    ];
    int tie(String key) {
      if (key.startsWith('dup:')) return 1000 + dupOrder.indexOf(key);
      final field = VisitingCardFieldTransform.fieldFromKey(key);
      if (field == null) return 0;
      return VisitingCardFieldTransform.naturalZ(field);
    }

    keys.sort((a, b) {
      final byZ = VisitingCardFieldTransform
          .stackZ(a, currentOverlays[a])
          .compareTo(VisitingCardFieldTransform.stackZ(b, currentOverlays[b]));
      if (byZ != 0) return byZ;
      return tie(a).compareTo(tie(b));
    });
    return keys;
  }

  void _moveSelectedStack({required bool toFront}) {
    final field = selectedOverlay;
    final dupId = selectedDuplicateId;
    if (field == null && dupId == null) return;
    final key = dupId != null
        ? duplicateKey(dupId)
        : VisitingCardFieldTransform.keyOf(field!);
    final ordered = _visibleStackKeys();
    if (!ordered.contains(key)) ordered.add(key);
    final already = toFront ? ordered.last == key : ordered.first == key;
    if (already) return;
    ordered.remove(key);
    if (toFront) {
      ordered.add(key);
    } else {
      ordered.insert(0, key);
    }
    for (var i = 0; i < ordered.length; i++) {
      final itemKey = ordered[i];
      if (!itemKey.startsWith('dup:')) {
        final itemField = VisitingCardFieldTransform.fieldFromKey(itemKey);
        if (itemField != null) _ensureOverlay(itemField);
      }
      final current = currentOverlays[itemKey];
      if (current == null || current.zIndex == i) continue;
      currentOverlays[itemKey] = current.copyWith(zIndex: i);
    }
    notifyListeners();
  }

  /// Landscape Lock: hide the eight resize dots on the selected field.
  void toggleSelectedOverlayLock() {
    final current = activeTransform;
    if (current == null) return;
    _putActive(current.copyWith(locked: !current.locked));
  }

  VisitingCardOverlayField? get _fontSourceField {
    if (selectedDuplicateId != null) {
      final source =
          currentOverlays[duplicateKey(selectedDuplicateId!)]?.duplicateOf;
      return VisitingCardFieldTransform.fieldFromKey(source ?? '');
    }
    return selectedOverlay;
  }

  VisitingCardFieldPosition? selectedTextPosition() {
    final field = _fontSourceField;
    if (field == null || field.isImageOverlay) return null;
    final layout = VisitingCardPositionConfig.forTemplate(
      templateId: templateId,
      isHorizontal: isHorizontal,
    );
    final side = isFront ? layout.front : layout.back;
    return switch (field) {
      VisitingCardOverlayField.name => side.name,
      VisitingCardOverlayField.designation => side.designation,
      VisitingCardOverlayField.company => side.company,
      VisitingCardOverlayField.tagline => side.tagline,
      VisitingCardOverlayField.phone => side.phone,
      VisitingCardOverlayField.email => side.email,
      VisitingCardOverlayField.website => side.website,
      VisitingCardOverlayField.address => side.address,
      VisitingCardOverlayField.logo || VisitingCardOverlayField.qr => null,
    };
  }

  bool get selectedFontIsBold {
    final current = activeTransform;
    if (current == null) return false;
    if (current.fontBoldMode == 1) return true;
    if (current.fontBoldMode == 2) return false;
    final preset = VisitingCardFontPreset.of(current.fontPreset);
    if (preset != null) return preset.bold;
    final weight = selectedTextPosition()?.fontWeight ?? FontWeight.w400;
    return weight.value >= FontWeight.w600.value;
  }

  bool get selectedFontIsItalic {
    final current = activeTransform;
    if (current == null) return false;
    if (current.fontItalicMode == 1) return true;
    if (current.fontItalicMode == 2) return false;
    return selectedTextPosition()?.fontStyle == FontStyle.italic;
  }

  void setSelectedFontPreset(int index) {
    final current = activeTransform;
    if (current == null || selectedIsImage) return;
    if (index < 0 || index >= VisitingCardFontPreset.presets.length) return;
    final preset = VisitingCardFontPreset.presets[index];
    _putActive(
      current.copyWith(
        fontPreset: index,
        fontBoldMode: preset.bold ? 1 : 2,
      ),
    );
  }

  void toggleSelectedFontBold() {
    final current = activeTransform;
    if (current == null || selectedIsImage) return;
    _putActive(current.copyWith(fontBoldMode: selectedFontIsBold ? 2 : 1));
  }

  void toggleSelectedFontItalic() {
    final current = activeTransform;
    if (current == null || selectedIsImage) return;
    _putActive(current.copyWith(fontItalicMode: selectedFontIsItalic ? 2 : 1));
  }

  void toggleSelectedFontUnderline() {
    final current = activeTransform;
    if (current == null || selectedIsImage) return;
    _putActive(current.copyWith(fontUnderline: !current.fontUnderline));
  }

  void toggleSelectedFontStrike() {
    final current = activeTransform;
    if (current == null || selectedIsImage) return;
    _putActive(current.copyWith(fontStrike: !current.fontStrike));
  }

  void flipSelectedOverlay({required bool horizontal}) {
    final current = activeTransform;
    if (current == null) return;
    _putActive(
      horizontal
          ? current.copyWith(flipX: !current.flipX)
          : current.copyWith(flipY: !current.flipY),
    );
  }

  void setSelectedOverlayColor(Color color) {
    if (selectedIsImage && !selectedIsShape) return;
    final current = activeTransform;
    if (current == null) return;
    _putActive(current.copyWith(textColorValue: color.toARGB32()));
  }

  static const textSizeMin = 4.0;
  static const textSizeMax = 28.0;
  static const imageSizeMin = 0.06;
  static const imageSizeMax = 0.55;

  /// Slider position 0–1 for the selected field's current size.
  double selectedOverlaySizeFraction() {
    final current = activeTransform;
    if (current == null) return 0;
    final min = selectedIsImage ? imageSizeMin : textSizeMin;
    final max = selectedIsImage ? imageSizeMax : textSizeMax;
    return ((current.size - min) / (max - min)).clamp(0.0, 1.0);
  }

  /// Landscape Size slider. [fraction] is 0–1 across the field's size range.
  void setSelectedOverlaySizeFraction(double fraction) {
    final current = activeTransform;
    if (current == null) return;
    final t = fraction.clamp(0.0, 1.0);
    final min = selectedIsImage ? imageSizeMin : textSizeMin;
    final max = selectedIsImage ? imageSizeMax : textSizeMax;
    _putActive(current.copyWith(size: min + t * (max - min)));
  }

  double selectedAdjustFraction(String tool) {
    final current = activeTransform;
    if (current == null) return tool == 'Opacity' ? 1 : 0;
    return switch (tool) {
      'Rotate' => _unitTurns(current.rotation),
      'Opacity' => current.opacity.clamp(0.0, 1.0),
      'Spacing' => (current.letterSpacing / 12).clamp(0.0, 1.0),
      'Stroke' => (current.strokeWidth / 8).clamp(0.0, 1.0),
      'Shadow' => (current.shadowBlur / 18).clamp(0.0, 1.0),
      _ => 0,
    };
  }

  void setSelectedAdjustFraction(String tool, double fraction) {
    final current = activeTransform;
    if (current == null) return;
    if (tool != 'Rotate' && tool != 'Opacity' && selectedIsImage) return;
    final f = fraction.clamp(0.0, 1.0);
    _putActive(
      switch (tool) {
        'Rotate' => current.copyWith(rotation: f * math.pi * 2),
        'Opacity' => current.copyWith(opacity: f),
        'Spacing' => current.copyWith(letterSpacing: f * 12),
        'Stroke' => current.copyWith(strokeWidth: f * 8),
        'Shadow' => current.copyWith(shadowBlur: f * 18),
        _ => current,
      },
    );
  }

  void setSelectedStrokeColor(Color color) =>
      _setSelectedPaintColor(stroke: true, color: color);

  void setSelectedShadowColor(Color color) =>
      _setSelectedPaintColor(stroke: false, color: color);

  void _setSelectedPaintColor({required bool stroke, required Color color}) {
    if (selectedIsImage) return;
    final current = activeTransform;
    if (current == null) return;
    final argb = color.toARGB32();
    _putActive(
      stroke
          ? current.copyWith(strokeColorValue: argb)
          : current.copyWith(shadowColorValue: argb),
    );
  }

  double _unitTurns(double radians) {
    var turns = radians / (math.pi * 2);
    turns = turns - turns.floorToDouble();
    if (turns < 0) turns += 1;
    return turns.clamp(0.0, 1.0);
  }

  /// Landscape: corner drag — keep opposite corner fixed while scaling.
  void scaleOverlayUniform(
    VisitingCardOverlayField field,
    double pixelDelta,
    Size cardSize, {
    bool fixRight = false,
    bool fixBottom = false,
    double? seedWidthFraction,
    double? seedHeightPx,
    String? duplicateId,
  }) {
    if (cardSize.width <= 0 || cardSize.height <= 0) return;
    final key = duplicateId == null
        ? VisitingCardFieldTransform.keyOf(field)
        : duplicateKey(duplicateId);
    if (duplicateId == null) _ensureOverlay(field);
    final current = currentOverlays[key];
    if (current == null) return;
    final isImage = duplicateId == null
        ? field.isImageOverlay
        : _sourceIsImage(current.duplicateOf);
    var left = current.left;
    var top = current.top;

    if (isImage) {
      final next =
          (current.size + pixelDelta / cardSize.width).clamp(0.06, 0.55);
      final applied = next - current.size;
      if (fixRight) {
        left = (left - applied).clamp(-0.2, 0.95);
      }
      if (fixBottom) {
        top = (top - applied * cardSize.width / cardSize.height)
            .clamp(-0.2, 0.95);
      }
      currentOverlays[key] =
          current.copyWith(size: next, left: left, top: top);
    } else {
      final nextSize = (current.size + pixelDelta * 0.08).clamp(4.0, 28.0);
      final baseW = current.width ?? seedWidthFraction ?? 0.2;
      final nextW = (baseW + pixelDelta / cardSize.width).clamp(0.05, 1.0);
      final appliedW = nextW - baseW;
      if (fixRight) {
        left = (left - appliedW).clamp(-0.2, 0.95);
      }
      if (fixBottom && current.size > 0) {
        final oldH = seedHeightPx ?? (current.size * 1.2);
        final newH = oldH * (nextSize / current.size);
        top = (top - (newH - oldH) / cardSize.height).clamp(-0.2, 0.95);
      }
      currentOverlays[key] = current.copyWith(
        size: nextSize,
        width: nextW,
        left: left,
        top: top,
      );
    }
    notifyListeners();
  }

  /// Landscape: edge-center drag — stretch one axis; optionally keep the
  /// opposite edge fixed (left handle → fix right, top handle → fix bottom).
  void stretchOverlayAxis(
    VisitingCardOverlayField field, {
    required bool horizontal,
    required double pixelDelta,
    required Size cardSize,
    bool fixOpposite = false,
    double? seedWidthFraction,
    double? seedHeightPx,
    String? duplicateId,
  }) {
    if (cardSize.width <= 0 || cardSize.height <= 0) return;
    final key = duplicateId == null
        ? VisitingCardFieldTransform.keyOf(field)
        : duplicateKey(duplicateId);
    if (duplicateId == null) _ensureOverlay(field);
    final current = currentOverlays[key];
    if (current == null) return;
    final isImage = duplicateId == null
        ? field.isImageOverlay
        : _sourceIsImage(current.duplicateOf);
    if (horizontal) {
      if (isImage) {
        final next =
            (current.size + pixelDelta / cardSize.width).clamp(0.06, 0.55);
        final applied = next - current.size;
        final left = fixOpposite
            ? (current.left - applied).clamp(-0.2, 0.95)
            : current.left;
        currentOverlays[key] =
            current.copyWith(size: next, left: left);
      } else {
        // Seed from the current tight text box so the first drag doesn't
        // jump to a large template fraction (extra empty right space).
        final baseW = current.width ?? seedWidthFraction ?? 0.2;
        final nextW =
            (baseW + pixelDelta / cardSize.width).clamp(0.05, 1.0);
        final applied = nextW - baseW;
        final left = fixOpposite
            ? (current.left - applied).clamp(-0.2, 0.95)
            : current.left;
        currentOverlays[key] =
            current.copyWith(width: nextW, left: left);
      }
    } else {
      if (isImage) {
        final next =
            (current.size + pixelDelta / cardSize.height).clamp(0.06, 0.55);
        final appliedPx = (next - current.size) * cardSize.height;
        final top = fixOpposite
            ? (current.top - appliedPx / cardSize.height).clamp(-0.2, 0.95)
            : current.top;
        currentOverlays[key] =
            current.copyWith(size: next, top: top);
      } else {
        final nextSize =
            (current.size + pixelDelta * 0.08).clamp(4.0, 28.0);
        var top = current.top;
        if (fixOpposite && current.size > 0) {
          final oldH = seedHeightPx ?? (current.size * 1.2);
          final newH = oldH * (nextSize / current.size);
          top = (top - (newH - oldH) / cardSize.height).clamp(-0.2, 0.95);
        }
        currentOverlays[key] =
            current.copyWith(size: nextSize, top: top);
      }
    }
    notifyListeners();
  }

  void rotateOverlay(
    VisitingCardOverlayField field,
    double absoluteRadians, {
    String? duplicateId,
  }) {
    final key = duplicateId == null
        ? VisitingCardFieldTransform.keyOf(field)
        : duplicateKey(duplicateId);
    if (duplicateId == null) _ensureOverlay(field);
    final current = currentOverlays[key];
    if (current == null) return;
    currentOverlays[key] = current.copyWith(rotation: absoluteRadians);
    notifyListeners();
  }

  /// Copy editable contact fields from scanner / another edit VM.
  void applyContactFrom(VisitingCardEditContactViewModel other) {
    _replaceEntries(names, other.names);
    _replaceEntries(designations, other.designations);
    _replaceEntries(companies, other.companies);
    _replaceEntries(taglines, other.taglines);
    _replaceEntries(phones, other.phones, fallbackType: 'Cell');
    _replaceEntries(emails, other.emails, fallbackType: 'Company');
    _replaceEntries(websites, other.websites, fallbackType: 'Company');
    _replaceEntries(addresses, other.addresses);
    qrAssetPath = other.qrAssetPath;
    logoAssetPath = other.logoAssetPath;
    hasChosenQr = other.hasChosenQr;
    hasChosenLogo = other.hasChosenLogo;
    frontOverlays
      ..clear()
      ..addAll(other.frontOverlays);
    backOverlays
      ..clear()
      ..addAll(other.backOverlays);
    selectedOverlay = null;
    selectedDuplicateId = null;
    notifyListeners();
  }

  void applyContactLists({
    required List<ContactFieldEntry> names,
    required List<ContactFieldEntry> designations,
    required List<ContactFieldEntry> companies,
    required List<ContactFieldEntry> phones,
    required List<ContactFieldEntry> emails,
    required List<ContactFieldEntry> websites,
    required List<ContactFieldEntry> addresses,
    List<ContactFieldEntry>? taglines,
    String? qrAssetPath,
    String? logoAssetPath,
    bool? hasChosenQr,
    bool? hasChosenLogo,
    VisitingCardFieldTransforms? fieldTransforms,
  }) {
    _replaceEntries(this.names, names);
    _replaceEntries(this.designations, designations);
    _replaceEntries(this.companies, companies);
    _replaceEntries(this.taglines, taglines ?? const []);
    _replaceEntries(this.phones, phones, fallbackType: 'Cell');
    _replaceEntries(this.emails, emails, fallbackType: 'Company');
    _replaceEntries(this.websites, websites, fallbackType: 'Company');
    _replaceEntries(this.addresses, addresses);
    if (qrAssetPath != null) {
      this.qrAssetPath = qrAssetPath.isEmpty ? null : qrAssetPath;
      this.hasChosenQr = hasChosenQr ?? qrAssetPath.isNotEmpty;
    } else if (hasChosenQr != null) {
      this.hasChosenQr = hasChosenQr;
    }
    if (logoAssetPath != null) {
      this.logoAssetPath = logoAssetPath.isEmpty ? null : logoAssetPath;
      this.hasChosenLogo = hasChosenLogo ?? logoAssetPath.isNotEmpty;
    } else if (hasChosenLogo != null) {
      this.hasChosenLogo = hasChosenLogo;
    }
    if (fieldTransforms != null) {
      frontOverlays
        ..clear()
        ..addAll(fieldTransforms.front);
      backOverlays
        ..clear()
        ..addAll(fieldTransforms.back);
      selectedOverlay = null;
      selectedDuplicateId = null;
    }
    notifyListeners();
  }

  void _replaceEntries(
    List<ContactFieldEntry> target,
    List<ContactFieldEntry> source, {
    String fallbackType = '',
  }) {
    final maxName = identical(target, names) ? maxDisplayNameLength : null;
    target
      ..clear()
      ..addAll(
        source.map((e) {
          var value = e.value;
          if (maxName != null && value.length > maxName) {
            value = value.substring(0, maxName);
          }
          return ContactFieldEntry(value: value, type: e.type);
        }),
      );
    if (target.isEmpty) {
      target.add(ContactFieldEntry(type: fallbackType));
    }
  }

  void chooseQrCode() {
    if (!canEditQr) return;
    hasChosenQr = true;
    qrAssetPath = ui.AppAssets.defaultQrcodeIcon;
    notifyListeners();
  }

  void applyQrImage(String path) {
    hasChosenQr = true;
    qrAssetPath = path;
    notifyListeners();
  }

  void chooseLogo() {
    if (!canEditLogo) return;
    hasChosenLogo = true;
    logoAssetPath = ui.AppAssets.visitingTemplateLocalFileUploadIcon;
    notifyListeners();
  }

  void applyLogoImage(String path) {
    hasChosenLogo = true;
    logoAssetPath = path;
    notifyListeners();
  }

  /// Puts logo and QR back to a previous snapshot. Used when Profile is closed
  /// without Save.
  void restoreLogoAndQr({
    required String? logoPath,
    required bool hasLogo,
    required String? qrPath,
    required bool hasQr,
  }) {
    logoAssetPath = logoPath;
    hasChosenLogo = hasLogo;
    qrAssetPath = qrPath;
    hasChosenQr = hasQr;
    notifyListeners();
  }

  Future<String> persistLogoFile(File source) async {
    final dir = await getApplicationDocumentsDirectory();
    final logoDir = Directory('${dir.path}/visiting_card/logo_embed');
    if (!await logoDir.exists()) {
      await logoDir.create(recursive: true);
    }
    final ext = source.path.contains('.')
        ? source.path.split('.').last
        : 'jpg';
    final dest = File(
      '${logoDir.path}/logo_${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
    await source.copy(dest.path);
    return dest.path;
  }

  void updateSimpleField(
    List<ContactFieldEntry> list,
    int index,
    String value,
  ) {
    if (index < 0 || index >= list.length) return;
    var next = value;
    if (identical(list, names) && next.length > maxDisplayNameLength) {
      next = next.substring(0, maxDisplayNameLength);
    }
    list[index].value = next;
    _clearErrorForList(list);
    notifyListeners();
  }

  void updateTypedField(
    List<ContactFieldEntry> list,
    int index, {
    String? value,
    String? type,
  }) {
    if (index < 0 || index >= list.length) return;
    if (value != null) list[index].value = value;
    if (type != null) list[index].type = type;
    _clearErrorForList(list);
    notifyListeners();
  }

  void clearField(List<ContactFieldEntry> list, int index) {
    if (index < 0 || index >= list.length) return;
    list[index].value = '';
    _clearErrorForList(list);
    notifyListeners();
  }

  void addField(
    List<ContactFieldEntry> list, {
    required String defaultType,
  }) {
    list.add(ContactFieldEntry(type: defaultType));
    notifyListeners();
  }

  void removeField(List<ContactFieldEntry> list, int index) {
    if (list.length <= 1) {
      clearField(list, index);
      return;
    }
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    _clearErrorForList(list);
    notifyListeners();
  }

  void _clearErrorForList(List<ContactFieldEntry> list) {
    if (identical(list, names)) {
      invalidFields.remove(ContactValidationField.name);
    } else if (identical(list, designations)) {
      invalidFields.remove(ContactValidationField.designation);
    } else if (identical(list, companies)) {
      invalidFields.remove(ContactValidationField.company);
    } else if (identical(list, phones)) {
      invalidFields.remove(ContactValidationField.phone);
    } else if (identical(list, emails)) {
      invalidFields.remove(ContactValidationField.email);
    } else if (identical(list, addresses)) {
      invalidFields.remove(ContactValidationField.address);
    }
  }

  void applyContactFromSaved(
    SavedContactInfo contact, {
    String? savedFileId,
    String? contactFolderPath,
    String? folderId,
    String? dateTime,
  }) {
    editingSavedFileId = savedFileId;
    editingContactFolderPath = contactFolderPath;
    editingFolderId = folderId;
    editingDateTime = dateTime;

    _replaceEntries(names, [ContactFieldEntry(value: contact.name)]);
    _replaceEntries(
      designations,
      [ContactFieldEntry(value: contact.designation)],
    );
    _replaceEntries(companies, [ContactFieldEntry(value: contact.company)]);
    _replaceEntries(taglines, [ContactFieldEntry(value: contact.tagline)]);
    _replaceEntries(
      phones,
      contact.phones.isEmpty
          ? [ContactFieldEntry(type: 'Cell')]
          : contact.phones
              .map((e) => ContactFieldEntry(value: e.value, type: e.type))
              .toList(),
      fallbackType: 'Cell',
    );
    _replaceEntries(
      emails,
      contact.emails.isEmpty
          ? [ContactFieldEntry(type: 'Company')]
          : contact.emails
              .map((e) => ContactFieldEntry(value: e.value, type: e.type))
              .toList(),
      fallbackType: 'Company',
    );
    _replaceEntries(
      websites,
      contact.websites.isEmpty
          ? [ContactFieldEntry(type: 'Company')]
          : contact.websites
              .map((e) => ContactFieldEntry(value: e.value, type: e.type))
              .toList(),
      fallbackType: 'Company',
    );
    _replaceEntries(
      addresses,
      contact.addresses.isEmpty
          ? [ContactFieldEntry()]
          : contact.addresses.map((e) => ContactFieldEntry(value: e)).toList(),
    );

    hasChosenQr = contact.hasChosenQr;
    hasChosenLogo = contact.hasChosenLogo;
    qrAssetPath = contact.qrImagePath.isNotEmpty
        ? contact.qrImagePath
        : (hasChosenQr ? ui.AppAssets.defaultQrcodeIcon : qrAssetPath);
    logoAssetPath =
        contact.logoImagePath.isNotEmpty ? contact.logoImagePath : null;
    applyFieldTransforms(contact.fieldTransforms);
  }

  void clearEditingState() {
    editingSavedFileId = null;
    editingContactFolderPath = null;
    editingFolderId = null;
    editingDateTime = null;
  }

  /// Same shape as scanner [SavedContactInfo] for share / phone contacts.
  SavedContactInfo buildSavedContact({List<String> imagePaths = const []}) {
    return SavedContactInfo(
      name: names.first.value.trim(),
      designation: designations.first.value.trim(),
      company: companies.first.value.trim(),
      tagline: taglines.isNotEmpty ? taglines.first.value.trim() : '',
      phones: phones
          .where((e) => e.value.trim().isNotEmpty)
          .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
          .toList(),
      emails: emails
          .where((e) => e.value.trim().isNotEmpty)
          .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
          .toList(),
      websites: websites
          .where((e) => e.value.trim().isNotEmpty)
          .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
          .toList(),
      addresses: addresses
          .map((e) => e.value.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      imagePaths: imagePaths,
      source: SavedContactInfo.sourceTemplate,
      templateId: templateId,
      qrImagePath: qrAssetPath ?? '',
      logoImagePath: logoAssetPath ?? '',
      hasChosenQr: hasChosenQr,
      hasChosenLogo: hasChosenLogo,
      fieldTransforms: fieldTransformsSnapshot,
    );
  }

  /// Scanner visiting-card save: one contact folder + details → Recent + Folder.
  Future<bool> saveCard({
    required HomeViewModel homeViewModel,
    required FolderViewModel folderViewModel,
    required Future<Uint8List?> Function(int side) captureSide,
  }) async {
    if (isUpdatingExisting) {
      return updateCard(
        homeViewModel: homeViewModel,
        folderViewModel: folderViewModel,
        captureSide: captureSide,
      );
    }

    if (isSaving) return false;
    isSaving = true;
    notifyListeners();

    final previousSide = sideIndex;

    try {
      final frontBytes = await captureSide(0);
      final backBytes = await captureSide(1);

      sideIndex = previousSide;
      notifyListeners();

      if (frontBytes == null || backBytes == null) {
        isSaving = false;
        notifyListeners();
        return false;
      }

      final now = DateTime.now();
      final stamp = DateFormat('yyyyMMdd_HHmmss').format(now);
      final dateLabel = DateFormat('dd-MMM-yyyy HH:mm').format(now);

      final contactName = names.first.value.trim().isNotEmpty
          ? names.first.value.trim()
          : 'Visiting Card';
      final safeFolderName = _safeFolderName('${contactName}_$stamp');

      final docs = await getApplicationDocumentsDirectory();
      final contactFolder = Directory(
        p.join(
          docs.path,
          'Convert Document',
          'Visiting Card',
          safeFolderName,
        ),
      );
      await contactFolder.create(recursive: true);

      final embedded = await _persistEmbeddedAssets(contactFolder);
      final frontPath = p.join(contactFolder.path, 'card_front.jpg');
      final backPath = p.join(contactFolder.path, 'card_back.jpg');
      await File(frontPath).writeAsBytes(_toJpeg(frontBytes), flush: true);
      await File(backPath).writeAsBytes(_toJpeg(backBytes), flush: true);

      final imagePaths = [frontPath, backPath];
      final savedContact = SavedContactInfo(
        name: names.first.value.trim(),
        designation: designations.first.value.trim(),
        company: companies.first.value.trim(),
        tagline: taglines.isNotEmpty ? taglines.first.value.trim() : '',
        phones: phones
            .where((e) => e.value.trim().isNotEmpty)
            .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
            .toList(),
        emails: emails
            .where((e) => e.value.trim().isNotEmpty)
            .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
            .toList(),
        websites: websites
            .where((e) => e.value.trim().isNotEmpty)
            .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
            .toList(),
        addresses: addresses
            .map((e) => e.value.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        imagePaths: imagePaths,
        source: SavedContactInfo.sourceTemplate,
        templateId: templateId,
        qrImagePath: embedded.qrPath,
        logoImagePath: embedded.logoPath,
        hasChosenQr: hasChosenQr,
        hasChosenLogo: hasChosenLogo,
        fieldTransforms: fieldTransformsSnapshot,
      );
      await SavedContactInfo.writeToFolder(contactFolder.path, savedContact);
      final modelId = '${now.millisecondsSinceEpoch}';
      await File(p.join(contactFolder.path, 'contact_details.txt'))
          .writeAsString(_contactDetailsText(), flush: true);

      final displayName =
          savedContact.name.isNotEmpty ? savedContact.name : 'Visiting Card';
      final model = SavedFileModel(
        id: modelId,
        name: displayName,
        dateTime: dateLabel,
        path: contactFolder.path,
        pathImage: frontPath,
        fileType: 'visiting_card',
        folderId: FolderViewModel.visitingCardFolderId,
        isTextFile: false,
        contactJson: savedContact.toJsonString(),
      );
      await AppStorageService().storeAllFiles(model);

      await homeViewModel.loadRecentFromStorage();
      await folderViewModel.loadFromStorage();

      isSaving = false;
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('saveCard failed: $e\n$st');
      sideIndex = previousSide;
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCard({
    required HomeViewModel homeViewModel,
    required FolderViewModel folderViewModel,
    required Future<Uint8List?> Function(int side) captureSide,
  }) async {
    if (isSaving) return false;
    final folderPath = editingContactFolderPath;
    final fileId = editingSavedFileId;
    if (folderPath == null || fileId == null) return false;

    isSaving = true;
    notifyListeners();
    final previousSide = sideIndex;

    try {
      final frontBytes = await captureSide(0);
      final backBytes = await captureSide(1);
      sideIndex = previousSide;
      notifyListeners();

      if (frontBytes == null || backBytes == null) {
        isSaving = false;
        notifyListeners();
        return false;
      }

      final contactFolder = Directory(folderPath);
      await contactFolder.create(recursive: true);

      final embedded = await _persistEmbeddedAssets(contactFolder);
      final frontPath = p.join(contactFolder.path, 'card_front.jpg');
      final backPath = p.join(contactFolder.path, 'card_back.jpg');
      await File(frontPath).writeAsBytes(_toJpeg(frontBytes), flush: true);
      await File(backPath).writeAsBytes(_toJpeg(backBytes), flush: true);

      final savedContact = SavedContactInfo(
        name: names.first.value.trim(),
        designation: designations.first.value.trim(),
        company: companies.first.value.trim(),
        tagline: taglines.isNotEmpty ? taglines.first.value.trim() : '',
        phones: phones
            .where((e) => e.value.trim().isNotEmpty)
            .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
            .toList(),
        emails: emails
            .where((e) => e.value.trim().isNotEmpty)
            .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
            .toList(),
        websites: websites
            .where((e) => e.value.trim().isNotEmpty)
            .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
            .toList(),
        addresses: addresses
            .map((e) => e.value.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        imagePaths: [frontPath, backPath],
        source: SavedContactInfo.sourceTemplate,
        templateId: templateId,
        qrImagePath: embedded.qrPath,
        logoImagePath: embedded.logoPath,
        hasChosenQr: hasChosenQr,
        hasChosenLogo: hasChosenLogo,
        fieldTransforms: fieldTransformsSnapshot,
      );
      await SavedContactInfo.writeToFolder(contactFolder.path, savedContact);
      await File(p.join(contactFolder.path, 'contact_details.txt'))
          .writeAsString(_contactDetailsText(), flush: true);

      final displayName =
          savedContact.name.isNotEmpty ? savedContact.name : 'Visiting Card';
      final model = SavedFileModel(
        id: fileId,
        name: displayName,
        dateTime: editingDateTime ??
            DateFormat('dd-MMM-yyyy HH:mm').format(DateTime.now()),
        path: contactFolder.path,
        pathImage: frontPath,
        fileType: 'visiting_card',
        folderId: editingFolderId ?? FolderViewModel.visitingCardFolderId,
        isTextFile: false,
        contactJson: savedContact.toJsonString(),
      );
      await AppStorageService().updateFile(model);

      await homeViewModel.loadRecentFromStorage();
      await folderViewModel.loadFromStorage();
      clearEditingState();

      isSaving = false;
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('updateCard failed: $e\n$st');
      sideIndex = previousSide;
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<({String qrPath, String logoPath})> _persistEmbeddedAssets(
    Directory contactFolder,
  ) async {
    final embeddedDir = Directory(p.join(contactFolder.path, 'embedded'));
    if (!await embeddedDir.exists()) {
      await embeddedDir.create(recursive: true);
    }

    var qrPath = '';
    if (hasChosenQr && qrAssetPath != null && qrAssetPath!.isNotEmpty) {
      qrPath = await _persistEmbeddedFile(qrAssetPath!, embeddedDir, 'qr') ??
          qrAssetPath!;
      qrAssetPath = qrPath;
    }

    var logoPath = '';
    if (hasChosenLogo && logoAssetPath != null && logoAssetPath!.isNotEmpty) {
      logoPath =
          await _persistEmbeddedFile(logoAssetPath!, embeddedDir, 'logo') ??
              logoAssetPath!;
      logoAssetPath = logoPath;
    }

    return (qrPath: qrPath, logoPath: logoPath);
  }

  Future<String?> _persistEmbeddedFile(
    String sourcePath,
    Directory destDir,
    String baseName,
  ) async {
    if (sourcePath.startsWith('assets/')) return sourcePath;
    final src = File(sourcePath);
    if (!await src.exists()) return null;

    var ext = p.extension(sourcePath).toLowerCase();
    if (ext.isEmpty) ext = '.png';

    // Read FIRST — source may already live in [destDir] (previous update).
    final bytes = await src.readAsBytes();

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final dest = File(p.join(destDir.path, '${baseName}_$stamp$ext'));
    await dest.writeAsBytes(bytes, flush: true);

    await for (final entity in destDir.list()) {
      if (entity is! File) continue;
      if (p.equals(entity.path, dest.path)) continue;
      final name = p.basename(entity.path);
      if (name.startsWith('$baseName.') || name.startsWith('${baseName}_')) {
        try {
          await entity.delete();
        } catch (_) {}
      }
    }

    return dest.path;
  }

  Uint8List _toJpeg(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    return Uint8List.fromList(img.encodeJpg(decoded, quality: 92));
  }

  String _safeFolderName(String raw) {
    return raw
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  String _contactDetailsText() {
    final buffer = StringBuffer();
    void addLine(String label, String value) {
      final v = value.trim();
      if (v.isEmpty) return;
      buffer.writeln('$label: $v');
    }

    addLine('Name', names.first.value);
    addLine('Designation', designations.first.value);
    addLine('Company', companies.first.value);
    for (final phone in phones) {
      if (phone.value.trim().isNotEmpty) {
        buffer.writeln('${phone.type}: ${phone.value.trim()}');
      }
    }
    for (final email in emails) {
      if (email.value.trim().isNotEmpty) {
        buffer.writeln('Email (${email.type}): ${email.value.trim()}');
      }
    }
    for (final web in websites) {
      if (web.value.trim().isNotEmpty) {
        buffer.writeln('Website (${web.type}): ${web.value.trim()}');
      }
    }
    for (final address in addresses) {
      if (address.value.trim().isNotEmpty) {
        buffer.writeln('Address: ${address.value.trim()}');
      }
    }
    return buffer.isEmpty
        ? 'Visiting card contact (exported)'
        : buffer.toString();
  }

  /// Keeps the current card as the history point without an Undo step.
  void _absorbUnchangedEdit() {
    if (!_historyReady || _restoringHistory || overlayGestureActive) return;
    _historyPoint = _captureEditSnapshot();
  }

  void _recordEditHistory() {
    if (!_historyReady || _restoringHistory || overlayGestureActive) return;
    final next = _captureEditSnapshot();
    if (_historyPoint == null) {
      _historyPoint = next;
      return;
    }
    if (next.signature == _historyPoint!.signature) return;
    final now = DateTime.now();
    final sameBurst = _historyAt != null &&
        now.difference(_historyAt!) < const Duration(milliseconds: 500);
    if (!sameBurst) {
      _undoStack.add(_historyPoint!);
      if (_undoStack.length > _historyLimit) _undoStack.removeAt(0);
      _redoStack.clear();
    }
    _historyPoint = next;
    _historyAt = now;
  }

  _CardEditSnapshot _captureEditSnapshot() => _CardEditSnapshot.capture(this);

  void _applyEditSnapshot(_CardEditSnapshot snapshot) {
    _restoringHistory = true;
    _historyAt = null;
    snapshot.writeTo(this);
    selectedOverlay = null;
    selectedDuplicateId = null;
    overlayGestureActive = false;
    _historyPoint = snapshot;
    super.notifyListeners();
    _restoringHistory = false;
  }
}

class _CardEditSnapshot {
  _CardEditSnapshot({
    required this.signature,
    required this.templateId,
    required this.isHorizontal,
    required this.frontAssetWithoutData,
    required this.backAssetWithoutData,
    required this.logoAssetPath,
    required this.qrAssetPath,
    required this.hasChosenLogo,
    required this.hasChosenQr,
    required this.frontOverlays,
    required this.backOverlays,
    required this.names,
    required this.designations,
    required this.companies,
    required this.taglines,
    required this.phones,
    required this.emails,
    required this.websites,
    required this.addresses,
  });

  final String signature;
  final String templateId;
  final bool isHorizontal;
  final String frontAssetWithoutData;
  final String backAssetWithoutData;
  final String? logoAssetPath;
  final String? qrAssetPath;
  final bool hasChosenLogo;
  final bool hasChosenQr;
  final Map<String, VisitingCardFieldTransform> frontOverlays;
  final Map<String, VisitingCardFieldTransform> backOverlays;
  final List<ContactFieldEntry> names;
  final List<ContactFieldEntry> designations;
  final List<ContactFieldEntry> companies;
  final List<ContactFieldEntry> taglines;
  final List<ContactFieldEntry> phones;
  final List<ContactFieldEntry> emails;
  final List<ContactFieldEntry> websites;
  final List<ContactFieldEntry> addresses;

  static _CardEditSnapshot capture(VisitingCardEditContactViewModel vm) {
    final front = _copyOverlays(vm.frontOverlays);
    final back = _copyOverlays(vm.backOverlays);
    final names = _copyFields(vm.names);
    final designations = _copyFields(vm.designations);
    final companies = _copyFields(vm.companies);
    final taglines = _copyFields(vm.taglines);
    final phones = _copyFields(vm.phones);
    final emails = _copyFields(vm.emails);
    final websites = _copyFields(vm.websites);
    final addresses = _copyFields(vm.addresses);
    return _CardEditSnapshot(
      signature: [
        vm.templateId,
        vm.isHorizontal,
        vm.frontAssetWithoutData,
        vm.backAssetWithoutData,
        vm.logoAssetPath,
        vm.qrAssetPath,
        vm.hasChosenLogo,
        vm.hasChosenQr,
        _overlaySig(front),
        _overlaySig(back),
        _fieldSig(names),
        _fieldSig(designations),
        _fieldSig(companies),
        _fieldSig(taglines),
        _fieldSig(phones),
        _fieldSig(emails),
        _fieldSig(websites),
        _fieldSig(addresses),
      ].join('\u0000'),
      templateId: vm.templateId,
      isHorizontal: vm.isHorizontal,
      frontAssetWithoutData: vm.frontAssetWithoutData,
      backAssetWithoutData: vm.backAssetWithoutData,
      logoAssetPath: vm.logoAssetPath,
      qrAssetPath: vm.qrAssetPath,
      hasChosenLogo: vm.hasChosenLogo,
      hasChosenQr: vm.hasChosenQr,
      frontOverlays: front,
      backOverlays: back,
      names: names,
      designations: designations,
      companies: companies,
      taglines: taglines,
      phones: phones,
      emails: emails,
      websites: websites,
      addresses: addresses,
    );
  }

  void writeTo(VisitingCardEditContactViewModel vm) {
    vm.templateId = templateId;
    vm.isHorizontal = isHorizontal;
    vm.frontAssetWithoutData = frontAssetWithoutData;
    vm.backAssetWithoutData = backAssetWithoutData;
    vm.logoAssetPath = logoAssetPath;
    vm.qrAssetPath = qrAssetPath;
    vm.hasChosenLogo = hasChosenLogo;
    vm.hasChosenQr = hasChosenQr;
    vm.frontOverlays
      ..clear()
      ..addAll(_copyOverlays(frontOverlays));
    vm.backOverlays
      ..clear()
      ..addAll(_copyOverlays(backOverlays));
    _replaceFields(vm.names, names);
    _replaceFields(vm.designations, designations);
    _replaceFields(vm.companies, companies);
    _replaceFields(vm.taglines, taglines);
    _replaceFields(vm.phones, phones);
    _replaceFields(vm.emails, emails);
    _replaceFields(vm.websites, websites);
    _replaceFields(vm.addresses, addresses);
  }

  static Map<String, VisitingCardFieldTransform> _copyOverlays(
    Map<String, VisitingCardFieldTransform> source,
  ) {
    return {
      for (final entry in source.entries)
        entry.key: VisitingCardFieldTransform.fromJson(entry.value.toJson()),
    };
  }

  static String _overlaySig(Map<String, VisitingCardFieldTransform> map) {
    final keys = map.keys.toList()..sort();
    return [
      for (final key in keys) '$key:${map[key]!.toJson()}',
    ].join('|');
  }

  static List<ContactFieldEntry> _copyFields(List<ContactFieldEntry> source) {
    return [
      for (final entry in source)
        ContactFieldEntry(value: entry.value, type: entry.type),
    ];
  }

  static void _replaceFields(
    List<ContactFieldEntry> target,
    List<ContactFieldEntry> source,
  ) {
    target
      ..clear()
      ..addAll(_copyFields(source));
  }

  static String _fieldSig(List<ContactFieldEntry> list) {
    return [
      for (final entry in list) '${entry.type}\u0001${entry.value}',
    ].join('\u0002');
  }
}
