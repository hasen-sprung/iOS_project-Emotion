import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    private var records = [Record]()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct ShapeView: View {
    var image: UIImage?
    var color: Color
    
    init(level: Int) {
        self.image = ThemeManager.shared.getThemeInstance().getImageByGaugeLevel(gaugeLevel: level)
        self.color = Color(uiColor: ThemeManager.shared.getThemeInstance().getColorByGaugeLevel(gaugeLevel: level))
    }
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .renderingMode(.template)
                .foregroundColor(color)
        }
    }
}

struct CanvasWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            ShapeView(level: 20)
            ShapeView(level: 30)
            ShapeView(level: 40)
            ShapeView(level: 50)
        }
    }
}

@main
struct CanvasWidget: Widget {
    let kind: String = "CanvasWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CanvasWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Canvas")
        .description("Create your own Canvas!")
    }
}

struct CanvasWidget_Previews: PreviewProvider {
    static var previews: some View {
        CanvasWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        CanvasWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
