{ pkgs, ... }: {
  # Kanalı stabil tutalım
  channel = "stable-24.05"; 

  packages = [
    pkgs.flutter
    pkgs.jdk17
    pkgs.unzip
    # pkgs.android-sdk <- BU SATIR SİLİNDİ (Hataya bu sebep oluyordu)
  ];

  # Ortam değişkenleri sadeleştirildi. 
  # IDX, Android SDK yolunu genellikle otomatik bulur.
  env = {};

  idx = {
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];
    
    workspace = {
      # İlk açılışta sadece paketleri getirsin
      onCreate = { 
        build-flutter = "flutter pub get";
      };
      onStart = {
        build-flutter = "flutter pub get";
      };
    };

    previews = {
      enable = true;
      previews = {
        web = {
          command = ["flutter" "run" "--machine" "-d" "web-server" "--web-hostname" "0.0.0.0" "--web-port" "$PORT"];
          manager = "flutter";
        };
      };
    };
  };
}