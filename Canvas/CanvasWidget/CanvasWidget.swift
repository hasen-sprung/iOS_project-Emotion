import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
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
                .resizable()
                .renderingMode(.template)
                .frame(width: .infinity, height: .infinity, alignment: .center)
                .foregroundColor(color)
        }
    }
}

struct CanvasWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack{
            Color(uiColor: canvasColor).edgesIgnoringSafeArea(.all)
                .cornerRadius(15)
            GeometryReader { geometry in
                ForEach(0 ..< getIndex(recordNum: records.count)) { index in
                    let record = records[index]
                    
                    if let pos: Int = record.setPosition as? Int {
                        // MARK: - TODO: offset x: record.x y: record.y
                        ShapeView(level: Int(record.gaugeLevel))
                            .offset(x: CGFloat(positions[pos].xRatio) * geometry.size.width,
                                    y: CGFloat(positions[pos].yRatio) * geometry.size.height)
                            .frame(width: geometry.size.width / 7, height: geometry.size.height / 7, alignment: .center)
                    }
                }
            }
        }
        .padding(10)
        .background(Color(uiColor: bgColor))
    }
    
    var records: [Record] {
        let context = CoreDataStack.shared.managedObjectContext
        let request = Record.fetchRequest()
        var records: [Record] = [Record]()
        
        do {
            records = try context.fetch(request)
        } catch { print("context Error") }
        return records
    }
    
    var positions: [Position] {
        let context = CoreDataStack.shared.managedObjectContext
        let request = Position.fetchRequest()
        var positions: [Position] = [Position]()
        
        do {
            positions = try context.fetch(request)
        } catch { print("context Error") }
        return positions
    }
    
    private func getIndex(recordNum: Int) -> Int {
        if recordNum < 10 {
            return recordNum
        } else {
            return 10
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
        .supportedFamilies([.systemSmall, .systemLarge])
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
