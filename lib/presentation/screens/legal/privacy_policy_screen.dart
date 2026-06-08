import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

/// プライバシーポリシー画面
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyTitle),
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
            _buildPrivacyContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyContent(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isJapanese = locale.languageCode == 'ja';

    if (isJapanese) {
      return _buildJapanesePrivacy(context);
    } else {
      return _buildIndonesianPrivacy(context);
    }
  }

  Widget _buildJapanesePrivacy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          '1. データの保存',
          '本アプリは、以下のデータをお客様のデバイス内にローカル保存します：\n\n'
              '・学習履歴（アプリ内での学習進捗データ）\n'
              '・お気に入り登録したフレーズ\n'
              '・アプリ設定（言語、ダークモード等）\n\n'
              'これらのデータは、すべてお客様のデバイス内にのみ保存され、開発者や第三者のサーバーには一切送信されません。',
        ),
        _buildSection(
          '2. データの利用目的',
          'デバイスに保存されたデータは、以下の目的で利用されます：\n\n'
              '・アプリの機能提供（学習進捗の記録と表示）\n'
              '・ユーザー体験の向上\n\n'
              'これらのデータは、お客様のデバイス内でのみ使用され、外部に送信されることはありません。',
        ),
        _buildSection(
          '3. 個人情報の収集について',
          '本アプリは、個人を識別できる情報（氏名、メールアドレス、電話番号等）を一切収集しません。また、デバイス情報やユーザーの行動履歴を外部に送信することもありません。',
        ),
        _buildSection(
          '4. データの管理と削除',
          'お客様は、アプリをアンインストールすることで、デバイスに保存されたすべてのデータを削除することができます。',
        ),
        _buildSection(
          '5. インターネット接続とアプリ内課金',
          '本アプリの学習機能は完全オフラインで動作し、インターネット接続を必要としません。\n\n'
              'ただし、アプリ内課金（コンテンツパックの購入・購入の復元）を利用する場合のみ、App Store（Apple）および購入管理サービスのRevenueCat, Inc.との通信が行われます。\n\n'
              '・決済処理はAppleが行い、Appleのプライバシーポリシーが適用されます\n'
              '・購入状態の管理のため、匿名の識別子と購入履歴（レシート情報）がRevenueCatに送信されます。氏名・メールアドレス・クレジットカード情報が送信されることはありません\n'
              '・RevenueCatのプライバシーポリシー: https://www.revenuecat.com/privacy\n\n'
              '本アプリ自体が購入者の氏名・決済情報等の個人情報を収集・保存することはありません。',
        ),
        _buildSection(
          '6. Cookie等の使用',
          '本アプリは、Cookie、広告識別子、アクセス解析ツールを使用しません。',
        ),
        _buildSection(
          '7. 音声データの取扱い',
          '本アプリには音声再生機能（TTS: Text-to-Speech）が含まれていますが、音声データの録音や外部送信は行いません。すべての音声処理はデバイス内で完結します。',
        ),
        _buildSection(
          '8. お問い合わせ',
          '本プライバシーポリシーに関するお問い合わせは、以下のメールアドレスまでご連絡ください。\n\n'
              'メールアドレス: web-studio@ymail.ne.jp',
        ),
        _buildSection(
          '9. プライバシーポリシーの変更',
          '本プライバシーポリシーは、必要に応じて変更されることがあります。変更後のプライバシーポリシーは、本アプリ内に表示された時点から効力を生じます。',
        ),
      ],
    );
  }

  Widget _buildIndonesianPrivacy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          '1. Penyimpanan Data',
          'Aplikasi ini menyimpan data berikut secara lokal di perangkat Anda:\n\n'
              '・Riwayat pembelajaran (data kemajuan pembelajaran dalam aplikasi)\n'
              '・Frasa yang ditandai sebagai favorit\n'
              '・Pengaturan aplikasi (bahasa, mode gelap, dll.)\n\n'
              'Semua data ini hanya disimpan di perangkat Anda dan tidak pernah dikirim ke server pengembang atau pihak ketiga.',
        ),
        _buildSection(
          '2. Tujuan Penggunaan Data',
          'Data yang disimpan di perangkat digunakan untuk tujuan berikut:\n\n'
              '・Menyediakan fungsi aplikasi (mencatat dan menampilkan kemajuan pembelajaran)\n'
              '・Meningkatkan pengalaman pengguna\n\n'
              'Data ini hanya digunakan di dalam perangkat Anda dan tidak dikirim ke luar.',
        ),
        _buildSection(
          '3. Tentang Pengumpulan Informasi Pribadi',
          'Aplikasi ini tidak mengumpulkan informasi yang dapat mengidentifikasi individu (nama, alamat email, nomor telepon, dll.). Aplikasi ini juga tidak mengirim informasi perangkat atau riwayat perilaku pengguna ke luar.',
        ),
        _buildSection(
          '4. Pengelolaan dan Penghapusan Data',
          'Anda dapat menghapus semua data yang tersimpan di perangkat dengan menghapus instalasi aplikasi.',
        ),
        _buildSection(
          '5. Koneksi Internet dan Pembelian Dalam Aplikasi',
          'Fungsi pembelajaran aplikasi ini berfungsi sepenuhnya secara offline dan tidak memerlukan koneksi internet.\n\n'
              'Namun, komunikasi dengan App Store (Apple) dan layanan pengelolaan pembelian RevenueCat, Inc. hanya terjadi saat Anda menggunakan pembelian dalam aplikasi (pembelian paket konten atau pemulihan pembelian).\n\n'
              '・Proses pembayaran ditangani oleh Apple dan tunduk pada kebijakan privasi Apple\n'
              '・Untuk mengelola status pembelian, pengenal anonim dan riwayat pembelian (informasi struk) dikirim ke RevenueCat. Nama, alamat email, dan informasi kartu kredit tidak pernah dikirim\n'
              '・Kebijakan privasi RevenueCat: https://www.revenuecat.com/privacy\n\n'
              'Aplikasi ini sendiri tidak mengumpulkan atau menyimpan informasi pribadi pembeli seperti nama atau informasi pembayaran.',
        ),
        _buildSection(
          '6. Penggunaan Cookie',
          'Aplikasi ini tidak menggunakan Cookie, pengidentifikasi iklan, atau alat analisis akses.',
        ),
        _buildSection(
          '7. Penanganan Data Audio',
          'Aplikasi ini mencakup fungsi pemutaran audio (TTS: Text-to-Speech), tetapi tidak merekam atau mengirim data audio ke luar. Semua pemrosesan audio dilakukan di dalam perangkat.',
        ),
        _buildSection(
          '8. Kontak',
          'Untuk pertanyaan tentang Kebijakan Privasi ini, silakan hubungi kami di alamat email berikut:\n\n'
              'Email: web-studio@ymail.ne.jp',
        ),
        _buildSection(
          '9. Perubahan Kebijakan Privasi',
          'Kebijakan Privasi ini dapat diubah sesuai kebutuhan. Kebijakan Privasi yang diubah akan berlaku sejak ditampilkan di aplikasi.',
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
