import '../constants/modes.dart';

class HomeSection {
  final String title;
  final List<HomeGridItem> data;

  HomeSection({required this.title, required this.data});
}

class HomeGridItem {
  final String id;
  final String label;
  final String iconPath;
  final String? mode;
  final String? action;
  final String? url;

  HomeGridItem({
    required this.id,
    required this.label,
    required this.iconPath,
    this.mode,
    this.action,
    this.url,
  });
}

final List<HomeSection> homeSections = [
  HomeSection(
    title: 'General Barcodes',
    data: [
      HomeGridItem(
        id: '1d',
        label: '1D',
        iconPath: 'assets/icons/icon_1d.svg',
        mode: ScannerModes.mode1D,
      ),
      HomeGridItem(
        id: '2d',
        label: '2D',
        iconPath: 'assets/icons/icon_2d.svg',
        mode: ScannerModes.mode2D,
      ),
      HomeGridItem(
        id: 'continuous',
        label: 'Continuous',
        iconPath: 'assets/icons/icon_continuous.svg',
        mode: ScannerModes.continuous,
      ),
    ],
  ),
  HomeSection(
    title: 'Showcase',
    data: [
      HomeGridItem(
        id: 'multiscan',
        label: 'MultiScan',
        iconPath: 'assets/icons/icon_multiscan.svg',
        mode: ScannerModes.multiscan,
      ),
      HomeGridItem(
        id: 'vin',
        label: 'VIN',
        iconPath: 'assets/icons/icon_vin.svg',
        mode: ScannerModes.vin,
      ),
      HomeGridItem(
        id: 'dpm',
        label: 'DPM',
        iconPath: 'assets/icons/icon_dpm.svg',
        mode: ScannerModes.dpm,
      ),
      HomeGridItem(
        id: 'deblur',
        label: 'DeBlur',
        iconPath: 'assets/icons/icon_blur.svg',
        mode: ScannerModes.deblur,
      ),
      HomeGridItem(
        id: 'dotcode',
        label: 'DotCode',
        iconPath: 'assets/icons/icon_dotcode.svg',
        mode: ScannerModes.dotcode,
      ),
      HomeGridItem(
        id: 'ar_mode',
        label: 'AR Mode',
        iconPath: 'assets/icons/icon_ar.svg',
        mode: ScannerModes.arMode,
      ),
      HomeGridItem(
        id: 'mrz',
        label: 'MRZ',
        iconPath: 'assets/icons/icon_mrz.svg',
        mode: ScannerModes.mrz,
      ),
      HomeGridItem(
        id: 'gallery',
        label: 'Gallery Scan',
        iconPath: 'assets/icons/icon_gallery.svg',
        mode: ScannerModes.gallery,
      ),
    ],
  ),
];
