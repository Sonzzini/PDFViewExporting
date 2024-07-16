//
//  ContentView.swift
//  PDFExportSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 16/07/24.
//

import SwiftUI

struct ContentView: View {
	
	func exportToPDF() {
		guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
				let rootVC = windowScene.windows.first?.rootViewController else {
			print("Unable to access root view controller.")
			return
		}
		
		// Crie uma instância do UIHostingController com a ContentView e passe o body da sua View
		let hostingController = UIHostingController(rootView: self.body)
		
		rootVC.addChild(hostingController)
		hostingController.view.frame = rootVC.view.bounds
		rootVC.view.addSubview(hostingController.view)
		
		// Gerar dados do PDF
		let pdfData = hostingController.view.asPDF()
		
		// Criar um arquivo temporário
		let fileName = "exportedView.pdf"
		let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
		
		do {
			try pdfData.write(to: tempURL)
		} catch {
			print("Failed to write PDF data to temporary file: \(error)")
			return
		}
		
		// Criar e apresentar o UIActivityViewController
		let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
		
		// Configurar sourceView para iPad
		if let popoverController = activityVC.popoverPresentationController {
			popoverController.sourceView = hostingController.view
			popoverController.sourceRect = CGRect(x: hostingController.view.bounds.midX, y: hostingController.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}
		
		rootVC.present(activityVC, animated: true, completion: nil)
		
		hostingController.view.removeFromSuperview()
		hostingController.removeFromParent()
	}
	
	var body: some View {
		VStack {
			Image(systemName: "globe")
				.imageScale(.large)
				.foregroundStyle(.tint)
			
			Text("Hello, world!")
			
			Text("This is a sample project to let you export any view as a PDF file!")
				.padding()
			
			Button {
				exportToPDF()
			} label: {
				Text("Press me to export this view as a PDF!")
			}
		}
		.padding()
	}
}

#Preview {
	ContentView()
}

extension UIView {
	func asPDF() -> Data {
		let pdfRenderer = UIGraphicsPDFRenderer(bounds: bounds)
		return pdfRenderer.pdfData { context in
			context.beginPage()
			layer.render(in: context.cgContext)
		}
	}
}
