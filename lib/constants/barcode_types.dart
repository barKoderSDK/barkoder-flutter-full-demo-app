const List<Map<String, String>> barcodeTypes1D = [
  {'id': 'australianPost', 'label': 'Australian Post'},
  {'id': 'codabar', 'label': 'Codabar'},
  {'id': 'code11', 'label': 'Code 11'},
  {'id': 'code128', 'label': 'Code 128'},
  {'id': 'code25', 'label': 'Code 2 of 5 Standard'},
  {'id': 'code32', 'label': 'Code 32'},
  {'id': 'code39', 'label': 'Code 39'},
  {'id': 'code93', 'label': 'Code 93'},
  {'id': 'coop25', 'label': 'COOP 25'},
  {'id': 'datalogic25', 'label': 'Code 2 of 5 Datalogic'},
  {'id': 'databar14', 'label': 'GS1 Databar 14'},
  {'id': 'databarExpanded', 'label': 'GS1 Databar Expanded'},
  {'id': 'databarLimited', 'label': 'GS1 Databar Limited'},
  {'id': 'ean13', 'label': 'EAN 13'},
  {'id': 'ean8', 'label': 'EAN 8'},
  {'id': 'iata25', 'label': 'IATA 25'},
  {'id': 'interleaved25', 'label': 'Interleaved 2 of 5'},
  {'id': 'itf14', 'label': 'ITF 14'},
  {'id': 'japanesePost', 'label': 'Japanese Post'},
  {'id': 'kix', 'label': 'KIX'},
  {'id': 'matrix25', 'label': 'Matrix 25'},
  {'id': 'msi', 'label': 'MSI'},
  {'id': 'planet', 'label': 'Planet'},
  {'id': 'postalIMB', 'label': 'Postal IMB'},
  {'id': 'postnet', 'label': 'Postnet'},
  {'id': 'royalMail', 'label': 'Royal Mail'},
  {'id': 'telepen', 'label': 'Telepen'},
  {'id': 'upcA', 'label': 'UPC-A'},
  {'id': 'upcE', 'label': 'UPC-E'},
  {'id': 'upcE1', 'label': 'UPC-E1'},
];

const List<Map<String, String>> barcodeTypes2D = [
  {'id': 'aztec', 'label': 'Aztec'},
  {'id': 'aztecCompact', 'label': 'Aztec Compact'},
  {'id': 'datamatrix', 'label': 'Datamatrix'},
  {'id': 'dotcode', 'label': 'Dotcode'},
  {'id': 'idDocument', 'label': 'ID Document'},
  {'id': 'maxiCode', 'label': 'MaxiCode'},
  {'id': 'pdf417', 'label': 'PDF 417'},
  {'id': 'pdf417Micro', 'label': 'PDF 417 Micro'},
  {'id': 'qr', 'label': 'QR'},
  {'id': 'qrMicro', 'label': 'QR Micro'},
];

bool is1DBarcodeType(String type) {
  final normalized = type.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  return barcodeTypes1D.any(
    (t) =>
        t['label']!.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase() ==
            normalized ||
        t['id']!.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase() ==
            normalized,
  );
}
