import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

/// Photo-collage-style gallery picker for visiting-card logo.
/// Tap a photo (or camera) → returns that [File] immediately.
class VisitingCardLogoPickerScreen extends StatefulWidget {
  const VisitingCardLogoPickerScreen({super.key});

  static Future<File?> open(BuildContext context) {
    return Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const VisitingCardLogoPickerScreen()),
    );
  }

  @override
  State<VisitingCardLogoPickerScreen> createState() =>
      _VisitingCardLogoPickerScreenState();
}

class _VisitingCardLogoPickerScreenState
    extends State<VisitingCardLogoPickerScreen> {
  static const Color _bg = Color(0xFF1C1C1E);
  static const Color _accent = ui.Colors.parentIconSelectTextColor;

  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _gridScroll = ScrollController();
  final LayerLink _albumLayerLink = LayerLink();
  final GlobalKey _appbarKey = GlobalKey();

  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _currentAlbum;
  final List<AssetEntity> _galleryAssets = [];
  static final Map<String, Uint8List?> _thumbnailCache = {};

  OverlayEntry? _albumOverlay;
  bool _albumDropdownOpen = false;
  bool _loading = true;
  bool _loadingMore = false;
  bool _permissionDenied = false;
  bool _isPicking = false;
  int _page = 0;
  static const int _pageSize = 60;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _gridScroll.addListener(_onGridScroll);
    _initGallery();
  }

  @override
  void dispose() {
    _albumOverlay?.remove();
    _albumOverlay = null;
    _gridScroll.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openAlbumDropdown() {
    final overlay = Overlay.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final appbarBox =
        _appbarKey.currentContext?.findRenderObject() as RenderBox?;
    final appbarOffset = appbarBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final appbarHeight = appbarBox?.size.height ?? 56.h;

    _albumOverlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeAlbumDropdown,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          Positioned(
            top: appbarOffset.dy + appbarHeight,
            left: 0,
            width: screenWidth,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: screenWidth,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height -
                      appbarOffset.dy -
                      appbarHeight,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  shrinkWrap: true,
                  itemCount: _albums.length,
                  itemBuilder: (_, i) {
                    final album = _albums[i];
                    final isSelected = album.id == _currentAlbum?.id;
                    return FutureBuilder<AssetEntity?>(
                      future: album
                          .getAssetListRange(start: 0, end: 1)
                          .then((list) => list.isNotEmpty ? list.first : null),
                      builder: (context, snapshot) {
                        return InkWell(
                          onTap: () {
                            _closeAlbumDropdown();
                            _switchAlbum(album);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: SizedBox(
                                    width: 52.w,
                                    height: 52.w,
                                    child: snapshot.data != null
                                        ? _AssetThumbnail(
                                            asset: snapshot.data!,
                                            cache: _thumbnailCache,
                                          )
                                        : ColoredBox(
                                            color: Colors.grey[800]!,
                                          ),
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Text(
                                    album.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? _accent
                                          : Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                FutureBuilder<int>(
                                  future: album.assetCountAsync,
                                  builder: (context, countSnap) {
                                    return Text(
                                      countSnap.data?.toString() ?? '',
                                      style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 14.sp,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_albumOverlay!);
    setState(() => _albumDropdownOpen = true);
  }

  void _closeAlbumDropdown() {
    _albumOverlay?.remove();
    _albumOverlay = null;
    if (mounted) setState(() => _albumDropdownOpen = false);
  }

  void _onGridScroll() {
    if (!_hasMore || _loadingMore) return;
    if (_gridScroll.position.pixels >=
        _gridScroll.position.maxScrollExtent - 400) {
      _loadGalleryPage();
    }
  }

  Future<void> _initGallery() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && permission != PermissionState.limited) {
      if (mounted) {
        setState(() {
          _permissionDenied = true;
          _loading = false;
        });
      }
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: false,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(
            type: OrderOptionType.createDate,
            asc: false,
          ),
        ],
      ),
    );

    if (!mounted) return;
    setState(() {
      _albums = albums;
      _currentAlbum = albums.isNotEmpty ? albums.first : null;
    });
    await _loadGalleryPage(reset: true);
  }

  Future<void> _loadGalleryPage({bool reset = false}) async {
    final album = _currentAlbum;
    if (album == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    if (reset) {
      _page = 0;
      _hasMore = true;
      _galleryAssets.clear();
      setState(() => _loading = true);
    } else {
      if (!_hasMore) return;
      setState(() => _loadingMore = true);
    }

    try {
      final batch = await album.getAssetListPaged(
        page: _page,
        size: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        if (reset) _galleryAssets.clear();
        _galleryAssets.addAll(batch);
        _page++;
        _hasMore = batch.length >= _pageSize;
        _loading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _switchAlbum(AssetPathEntity album) async {
    setState(() => _currentAlbum = album);
    await _loadGalleryPage(reset: true);
  }

  Future<void> _finish(File file) async {
    if (!mounted) return;
    Navigator.pop(context, file);
  }

  Future<void> _pickAsset(AssetEntity asset) async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final file = await asset.file;
      if (!mounted) return;
      if (file == null) {
        _toast('Could not load image.');
        return;
      }
      await _finish(file);
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _openCamera() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final x = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (x == null || !mounted) return;
      final bytes = await x.readAsBytes();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/vc_logo_cam_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(bytes);
      await _finish(file);
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
          if (_isPicking)
            const ColoredBox(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      key: _appbarKey,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          Expanded(
            child: CompositedTransformTarget(
              link: _albumLayerLink,
              child: GestureDetector(
                onTap: _albums.length <= 1
                    ? null
                    : (_albumDropdownOpen
                        ? _closeAlbumDropdown
                        : _openAlbumDropdown),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _currentAlbum?.name ?? 'Recent',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_albums.length > 1)
                      Icon(
                        _albumDropdownOpen
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: Colors.white70,
                        size: 26.sp,
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_permissionDenied) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            'Photo access is required to pick a logo.\nEnable it in Settings.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15.sp),
          ),
        ),
      );
    }
    if (_loading && _galleryAssets.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white54),
      );
    }

    return GridView.builder(
      controller: _gridScroll,
      padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 8.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4.w,
        crossAxisSpacing: 4.w,
      ),
      itemCount: 1 + _galleryAssets.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0) {
          return GestureDetector(
            onTap: _openCamera,
            child: ColoredBox(
              color: const Color(0xFFF5F5F5),
              child: Icon(
                Icons.camera_alt_outlined,
                color: Colors.grey[600],
                size: 40.sp,
              ),
            ),
          );
        }
        final assetIndex = index - 1;
        if (assetIndex >= _galleryAssets.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white38,
              ),
            ),
          );
        }
        final asset = _galleryAssets[assetIndex];
        return GestureDetector(
          key: ValueKey('gallery_${asset.id}'),
          onTap: _isPicking ? null : () => _pickAsset(asset),
          child: _AssetThumbnail(asset: asset, cache: _thumbnailCache),
        );
      },
    );
  }
}

class _AssetThumbnail extends StatefulWidget {
  const _AssetThumbnail({
    required this.asset,
    required this.cache,
  });

  final AssetEntity asset;
  final Map<String, Uint8List?> cache;

  @override
  State<_AssetThumbnail> createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<_AssetThumbnail> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant _AssetThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.id != widget.asset.id) {
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    final cached = widget.cache[widget.asset.id];
    if (cached != null) {
      if (mounted) {
        setState(() {
          _bytes = cached;
          _loading = false;
        });
      }
      return;
    }

    final data = await widget.asset.thumbnailDataWithSize(
      const ThumbnailSize.square(400),
    );
    widget.cache[widget.asset.id] = data;
    if (!mounted) return;
    setState(() {
      _bytes = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _bytes == null) {
      return ColoredBox(color: Colors.grey[850]!);
    }
    return Image.memory(
      _bytes!,
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
  }
}
