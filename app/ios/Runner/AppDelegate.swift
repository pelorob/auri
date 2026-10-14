import Flutter
import UIKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AuriFirma") {
      auriRegistraCanaleFirma(registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AuriOcr") {
      auriRegistraCanaleOcr(registrar.messenger())
    }
  }
}

/// Data di scadenza della firma, letta dal profilo incluso da SideStore (ISO-8601 UTC).
func auriScadenzaFirma() -> String? {
  guard let path = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision"),
        let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
        let text = String(data: data, encoding: .isoLatin1),
        let start = text.range(of: "<?xml"),
        let end = text.range(of: "</plist>") else { return nil }
  let xml = String(text[start.lowerBound..<end.upperBound])
  guard let plistData = xml.data(using: .isoLatin1),
        let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any],
        let date = plist["ExpirationDate"] as? Date else { return nil }
  let f = ISO8601DateFormatter()
  f.timeZone = TimeZone(identifier: "UTC")
  return f.string(from: date)
}

func auriRegistraCanaleFirma(_ messenger: FlutterBinaryMessenger) {
  let channel = FlutterMethodChannel(name: "auri/firma", binaryMessenger: messenger)
  channel.setMethodCallHandler { call, result in
    if call.method == "scadenza" { result(auriScadenzaFirma()) } else { result(FlutterMethodNotImplemented) }
  }
}

/// Riconoscimento del testo (Apple Vision, sul dispositivo): riceve un PNG, restituisce le righe lette.
func auriRegistraCanaleOcr(_ messenger: FlutterBinaryMessenger) {
  let channel = FlutterMethodChannel(name: "auri/ocr", binaryMessenger: messenger)
  channel.setMethodCallHandler { call, result in
    guard call.method == "leggi" else { result(FlutterMethodNotImplemented); return }
    guard let dati = call.arguments as? FlutterStandardTypedData,
          let immagine = UIImage(data: dati.data),
          let cg = immagine.cgImage else {
      result(FlutterError(code: "immagine", message: "Immagine non valida", details: nil))
      return
    }
    // Si risponde una sola volta, anche se Vision segnala l'errore sia qui sia da perform().
    var risposto = false
    let rispondi: (Any?) -> Void = { valore in
      DispatchQueue.main.async {
        if risposto { return }
        risposto = true
        result(valore)
      }
    }
    let richiesta = VNRecognizeTextRequest { req, errore in
      if let errore = errore {
        rispondi(FlutterError(code: "vision", message: errore.localizedDescription, details: nil))
        return
      }
      let righe = (req.results as? [VNRecognizedTextObservation] ?? []).compactMap { $0.topCandidates(1).first?.string }
      rispondi(righe.joined(separator: "\n"))
    }
    richiesta.recognitionLevel = .accurate
    richiesta.recognitionLanguages = ["it-IT", "en-US"]
    richiesta.usesLanguageCorrection = true
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try VNImageRequestHandler(cgImage: cg, options: [:]).perform([richiesta])
      } catch {
        rispondi(FlutterError(code: "vision", message: error.localizedDescription, details: nil))
      }
    }
  }
}
