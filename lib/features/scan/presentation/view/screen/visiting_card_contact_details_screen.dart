import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/home/domain/model/recent_card_item.dart';
import 'package:visiting_card/features/scan/domain/saved_contact_info.dart';
import 'package:visiting_card/features/scan/presentation/helper/visiting_card_share_helper.dart';
import 'package:visiting_card/features/scan/presentation/view/screen/visiting_card_scanned_contact_screen.dart';
import 'package:visiting_card/features/scan/presentation/view_model/visiting_card_scan_viewmodel.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_edit_field_cards.dart';

class VisitingCardContactDetailsScreen extends StatefulWidget {
  const VisitingCardContactDetailsScreen({super.key, required this.item});

  final RecentCardItem item;

  @override
  State<VisitingCardContactDetailsScreen> createState() =>
      _VisitingCardContactDetailsScreenState();
}

class _VisitingCardContactDetailsScreenState
    extends State<VisitingCardContactDetailsScreen> {
  SavedContactInfo? _contact;
  List<File> _images = const [];
  bool _loading = true;
  late final PageController _pageController;
  int _pageIndex = 0;

  List<BoxShadow> get _cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final folderPath = widget.item.path;
    final images = <File>[];
    SavedContactInfo? contact;

    if (folderPath != null && folderPath.isNotEmpty) {
      final dir = Directory(folderPath);
      if (dir.existsSync()) {
        contact = await SavedContactInfo.readFromFolder(folderPath);
        final front = File(p.join(folderPath, 'card_front.jpg'));
        final back = File(p.join(folderPath, 'card_back.jpg'));
        if (front.existsSync()) images.add(front);
        if (back.existsSync()) images.add(back);
        if (images.isEmpty && contact != null) {
          for (final path in contact.imagePaths) {
            final f = File(path);
            if (f.existsSync()) images.add(f);
          }
        }
      } else {
        final file = File(folderPath);
        if (file.existsSync()) images.add(file);
      }
    }

    final thumb = widget.item.thumbnailPath;
    if (images.isEmpty && thumb != null && File(thumb).existsSync()) {
      images.add(File(thumb));
    }

    if (!mounted) return;
    setState(() {
      _contact = contact;
      _images = images;
      _loading = false;
    });
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _call(String number) async {
    final cleaned = number.trim();
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMap(String address) async {
    final encoded = Uri.encodeComponent(address.trim());
    if (encoded.isEmpty) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWebsite(String url) async {
    var value = url.trim();
    if (value.isEmpty) return;
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'https://$value';
    }
    final uri = Uri.tryParse(value);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openEdit() async {
    final contact = _contact;
    if (contact == null && _images.isEmpty) {
      ui.AppToast.show(context, message: 'No contact data to edit');
      return;
    }

    final bytesList = <Uint8List>[];
    for (final file in _images) {
      if (await file.exists()) {
        bytesList.add(await file.readAsBytes());
      }
    }

    final editContact = contact ??
        SavedContactInfo(
          name: widget.item.name,
          imagePaths: _images.map((e) => e.path).toList(),
        );

    final vm = VisitingCardScanViewModel();
    await vm.loadFromSavedContact(
      contact: editContact,
      imageBytesList: bytesList,
      savedFileId: widget.item.id,
      contactFolderPath: widget.item.path,
      folderId: widget.item.folderId,
      dateTime: widget.item.dateTime,
    );
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const VisitingCardScannedContactScreen(),
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _shareCard() async {
    final contact = _contact ??
        SavedContactInfo(
          name: widget.item.name,
          imagePaths: _images.map((e) => e.path).toList(),
        );

    await VisitingCardShareHelper.showShareViaDialog(
      context,
      contact: contact,
      fallbackName: widget.item.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final contact = _contact;
    final name =
        (contact?.name.isNotEmpty == true) ? contact!.name : widget.item.name;
    final designation = contact?.designation ?? '';
    final company = contact?.company ?? '';
    final firstPhone = contact?.phones
            .where((e) => e.value.trim().isNotEmpty)
            .map((e) => e.value)
            .firstOrNull ??
        '';
    final firstAddress =
        contact?.addresses.where((e) => e.trim().isNotEmpty).firstOrNull ?? '';
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Card Details',
          style: ui.AppTextStyles.mainText().copyWith(
            fontSize: 18.sp,
            //color: ui.Colors.parentIconSelectTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 16.h),
                    children: [
                      if (_images.isNotEmpty) ...[
                        SizedBox(
                          height: 190.h,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                itemCount: _images.length,
                                onPageChanged: (i) =>
                                    setState(() => _pageIndex = i),
                                itemBuilder: (_, i) => ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Image.file(
                                    _images[i],
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                              // if (_images.length > 1)
                              //   Positioned(
                              //     left: 0,
                              //     right: 0,
                              //     bottom: 16.h,
                              //     child: Row(
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       children: [
                              //         GestureDetector(
                              //           onTap: _pageIndex == 0
                              //               ? null
                              //               : () => _pageController.previousPage(
                              //                     duration: const Duration(
                              //                         milliseconds: 250),
                              //                     curve: Curves.easeInOut,
                              //                   ),
                              //           child: SvgPicture.asset(
                              //             _pageIndex == 0
                              //                 ? ui.AppAssets
                              //                     .inactiveLeftSideArrow
                              //                 : ui.AppAssets
                              //                     .activeLeftSideArrow,
                              //             width: 28.w,
                              //             height: 28.w,
                              //           ),
                              //         ),
                              //         SizedBox(width: 1.w),
                              //         Container(
                              //           padding: EdgeInsets.symmetric(
                              //             horizontal: 8.w,
                              //             vertical: 3.h,
                              //           ),
                              //           decoration: BoxDecoration(
                              //             color: Colors.white,
                              //             borderRadius:
                              //                 BorderRadius.circular(6.r),
                              //             boxShadow: [
                              //               BoxShadow(
                              //                 color: Colors.black
                              //                     .withValues(alpha: 0.12),
                              //                 blurRadius: 6,
                              //                 offset: const Offset(0, 2),
                              //               ),
                              //             ],
                              //           ),
                              //           child: Text(
                              //             '${_pageIndex + 1}/${_images.length}',
                              //             style: TextStyle(
                              //               fontSize: 11.sp,
                              //               fontWeight: FontWeight.w600,
                              //               color: const Color(0xFF1A1A1A),
                              //             ),
                              //           ),
                              //         ),
                              //         SizedBox(width: 1.w),
                              //         GestureDetector(
                              //           onTap: _pageIndex >= _images.length - 1
                              //               ? null
                              //               : () => _pageController.nextPage(
                              //                     duration: const Duration(
                              //                         milliseconds: 250),
                              //                     curve: Curves.easeInOut,
                              //                   ),
                              //           child: SvgPicture.asset(
                              //             _pageIndex >= _images.length - 1
                              //                 ? ui.AppAssets
                              //                     .inactiveRightSideArrow
                              //                 : ui.AppAssets
                              //                     .activeRightSideArrow,
                              //             width: 28.w,
                              //             height: 28.w,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: _cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30.r,
                                  backgroundColor:
                                      ui.Colors.parentIconSelectTextColor,
                                  child: Text(
                                    _initials(name),
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      if (designation.trim().isNotEmpty)
                                        Text(
                                          designation,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      if (company.trim().isNotEmpty)
                                        Text(
                                          company,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            if (firstPhone.isNotEmpty)
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    ui.AppAssets.visitingTemplatePhoneIcon,
                                    width: 18.w,
                                    height: 18.w,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      firstPhone,
                                      style: TextStyle(fontSize: 13.sp),
                                    ),
                                  ),
                                ],
                              ),
                            if (firstAddress.isNotEmpty) ...[
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    ui.AppAssets.visitingTemplateLocationIcon,
                                    width: 18.w,
                                    height: 18.w,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      firstAddress,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13.sp),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: _cardShadow,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ActionColumn(
                              icon: ui.AppAssets.visitingTemplatePhoneIcon,
                              label: 'Tel',
                              onTap: firstPhone.isEmpty
                                  ? null
                                  : () => _call(firstPhone),
                            ),
                            _ActionColumn(
                              icon: ui.AppAssets.visitingTemplateLocationIcon,
                              label: 'Location',
                              onTap: firstAddress.isEmpty
                                  ? null
                                  : () => _openMap(firstAddress),
                            ),
                            _ActionColumn(
                              icon: ui.AppAssets.visitingTemplateEditIcon,
                              label: 'Edit',
                              onTap: _openEdit,
                            ),
                            _ActionColumn(
                              icon: ui.AppAssets.visitingTemplateShareIcon,
                              label: 'Share',
                              onTap: _shareCard,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      if (contact != null) ...[
                        ...contact.phones
                            .where((e) => e.value.trim().isNotEmpty)
                            .map(
                              (e) => _ContactLine(
                                icon: ui.AppAssets.visitingTemplatePhoneIcon,
                                value: e.value,
                                type: e.type.isEmpty ? 'Tel' : e.type,
                                onTap: () => _call(e.value),
                              ),
                            ),
                        ...contact.emails
                            .where((e) => e.value.trim().isNotEmpty)
                            .map(
                              (e) => _ContactLine(
                                icon: ui.AppAssets.visitingTemplateMailIcon,
                                value: e.value,
                                type: e.type.isEmpty ? 'Company' : e.type,
                                onTap: () => _openEmail(e.value),
                              ),
                            ),
                        if (company.trim().isNotEmpty)
                          _ContactLine(
                            icon: ui.AppAssets.visitingTemplateIcon,
                            value: company,
                            type: 'Company',
                          ),
                        ...contact.websites
                            .where((e) => e.value.trim().isNotEmpty)
                            .map(
                              (e) => _ContactLine(
                                icon: ui.AppAssets.visitingTemplateWebsiteIcon,
                                value: e.value,
                                type: e.type.isEmpty ? 'Website' : e.type,
                                onTap: () => _openWebsite(e.value),
                              ),
                            ),
                        ...contact.addresses
                            .where((e) => e.trim().isNotEmpty)
                            .map(
                              (e) => _ContactLine(
                                icon:
                                    ui.AppAssets.visitingTemplateLocationIcon,
                                value: e,
                                type: 'Address',
                                onTap: () => _openMap(e),
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    0,
                    16.w,
                    12.h + bottomInset,
                  ),
                  child: VisitingGradientButton(
                    label: 'Share Card',
                    onTap: _shareCard,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ActionColumn extends StatelessWidget {
  const _ActionColumn({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40.r),
      child: SizedBox(
        width: 72.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon, width: 22.w, height: 22.w),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({
    required this.icon,
    required this.value,
    required this.type,
    this.onTap,
  });

  final String icon;
  final String value;
  final String type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 6.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: SvgPicture.asset(icon, width: 20.w, height: 20.w),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
