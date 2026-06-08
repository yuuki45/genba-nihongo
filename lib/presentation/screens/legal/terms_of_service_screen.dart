import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

/// 利用規約画面
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.termsTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.lastUpdated}: 2026年06月07日',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            _buildTermsContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsContent(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isJapanese = locale.languageCode == 'ja';

    if (isJapanese) {
      return _buildJapaneseTerms(context);
    } else {
      return _buildIndonesianTerms(context);
    }
  }

  Widget _buildJapaneseTerms(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          '第1条（適用）',
          '本利用規約（以下「本規約」といいます）は、Nihongo（以下「本アプリ」といいます）の利用条件を定めるものです。本アプリを利用されるすべてのユーザーに適用されます。',
        ),
        _buildSection(
          '第2条（利用許諾）',
          '本アプリは、日本の工場で働くインドネシア人技能実習生の日本語学習を支援することを目的として提供されています。ユーザーは、本規約に同意することにより、本アプリを利用することができます。',
        ),
        _buildSection(
          '第3条（禁止事項）',
          'ユーザーは、本アプリの利用にあたり、以下の行為をしてはなりません。\n\n'
              '・法令または公序良俗に違反する行為\n'
              '・犯罪行為に関連する行為\n'
              '・本アプリの運営を妨害するおそれのある行為\n'
              '・他のユーザーに対する嫌がらせや誹謗中傷\n'
              '・本アプリの複製、改変、リバースエンジニアリング\n'
              '・その他、当方が不適切と判断する行為',
        ),
        _buildSection(
          '第4条（免責事項）',
          '本アプリは「現状有姿」で提供され、明示または黙示を問わず、いかなる保証も行いません。本アプリの利用により生じた損害について、当方は一切の責任を負いません。',
        ),
        _buildSection(
          '第5条（サービス内容の変更等）',
          '当方は、ユーザーへの事前の告知なく、本アプリの内容を変更、追加または廃止することがあり、ユーザーはこれを予め承諾するものとします。',
        ),
        _buildSection(
          '第6条（利用規約の変更）',
          '当方は、必要と判断した場合には、ユーザーへの事前の告知なく本規約を変更することができるものとします。変更後の本規約は、本アプリ内に表示された時点から効力を生じるものとします。',
        ),
        _buildSection(
          '第7条（個人情報の取扱い）',
          '本アプリにおける個人情報の取扱いについては、別途定めるプライバシーポリシーに従います。',
        ),
        _buildSection(
          '第8条（有料コンテンツ・アプリ内課金）',
          '本アプリは、追加コンテンツ（コンテンツパック）をアプリ内課金（買い切り）により提供することがあります。\n\n'
              '・課金処理はApple（App Store）を通じて行われ、Appleの利用規約が適用されます\n'
              '・購入したコンテンツは、同一のApple IDで「購入を復元」することにより再取得できます\n'
              '・返金については、Appleの返金ポリシーに従います。当方では直接返金の対応はできません\n'
              '・購入前に、内容と価格を十分にご確認ください',
        ),
        _buildSection(
          '第9条（準拠法・裁判管轄）',
          '本規約の解釈にあたっては、日本法を準拠法とします。本アプリに関して紛争が生じた場合には、東京地方裁判所を第一審の専属的合意管轄裁判所とします。',
        ),
      ],
    );
  }

  Widget _buildIndonesianTerms(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          'Pasal 1 (Penerapan)',
          'Ketentuan Layanan ini ("Ketentuan") mengatur ketentuan penggunaan aplikasi Nihongo ("Aplikasi"). Ketentuan ini berlaku untuk semua pengguna Aplikasi.',
        ),
        _buildSection(
          'Pasal 2 (Lisensi Penggunaan)',
          'Aplikasi ini disediakan untuk mendukung pembelajaran bahasa Jepang bagi pekerja magang teknis Indonesia yang bekerja di pabrik Jepang. Pengguna dapat menggunakan Aplikasi dengan menyetujui Ketentuan ini.',
        ),
        _buildSection(
          'Pasal 3 (Tindakan yang Dilarang)',
          'Pengguna tidak boleh melakukan tindakan berikut saat menggunakan Aplikasi:\n\n'
              '・Tindakan yang melanggar hukum atau ketertiban umum\n'
              '・Tindakan yang terkait dengan aktivitas kriminal\n'
              '・Tindakan yang dapat mengganggu operasi Aplikasi\n'
              '・Pelecehan atau pencemaran nama baik terhadap pengguna lain\n'
              '・Penyalinan, modifikasi, atau rekayasa balik Aplikasi\n'
              '・Tindakan lain yang kami anggap tidak pantas',
        ),
        _buildSection(
          'Pasal 4 (Penafian)',
          'Aplikasi disediakan "sebagaimana adanya" tanpa jaminan apa pun, baik tersurat maupun tersirat. Kami tidak bertanggung jawab atas kerusakan yang timbul dari penggunaan Aplikasi.',
        ),
        _buildSection(
          'Pasal 5 (Perubahan Konten Layanan)',
          'Kami dapat mengubah, menambah, atau menghentikan konten Aplikasi tanpa pemberitahuan sebelumnya kepada pengguna, dan pengguna menyetujui hal ini sebelumnya.',
        ),
        _buildSection(
          'Pasal 6 (Perubahan Ketentuan Layanan)',
          'Kami dapat mengubah Ketentuan ini tanpa pemberitahuan sebelumnya kepada pengguna jika dianggap perlu. Ketentuan yang diubah akan berlaku sejak ditampilkan di Aplikasi.',
        ),
        _buildSection(
          'Pasal 7 (Penanganan Informasi Pribadi)',
          'Penanganan informasi pribadi dalam Aplikasi akan mengikuti Kebijakan Privasi yang ditetapkan secara terpisah.',
        ),
        _buildSection(
          'Pasal 8 (Konten Berbayar dan Pembelian Dalam Aplikasi)',
          'Aplikasi ini dapat menyediakan konten tambahan (paket konten) melalui pembelian dalam aplikasi (sekali beli).\n\n'
              '・Proses pembayaran dilakukan melalui Apple (App Store) dan tunduk pada ketentuan layanan Apple\n'
              '・Konten yang dibeli dapat diperoleh kembali dengan "Pulihkan Pembelian" menggunakan Apple ID yang sama\n'
              '・Pengembalian dana mengikuti kebijakan pengembalian dana Apple. Kami tidak dapat memproses pengembalian dana secara langsung\n'
              '・Harap periksa konten dan harga dengan saksama sebelum membeli',
        ),
        _buildSection(
          'Pasal 9 (Hukum yang Berlaku dan Yurisdiksi)',
          'Ketentuan ini diatur oleh hukum Jepang. Jika terjadi perselisihan terkait Aplikasi, Pengadilan Distrik Tokyo akan menjadi pengadilan yurisdiksi eksklusif tingkat pertama.',
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
