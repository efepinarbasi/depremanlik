
class News {
  final String title;
  final String link;
  final String description;
  final DateTime pubDate;
  final String? source;

  News({
    required this.title,
    required this.link,
    required this.description,
    required this.pubDate,
    this.source,
  });

  factory News.fromXml(dynamic item) {
    // Note: This matches simple RSS structure
    // We'll use this in EarthquakeService with xml package
    return News(
      title: item.findElements('title').first.innerText,
      link: item.findElements('link').first.innerText,
      description: item.findElements('description').first.innerText,
      pubDate: DateTime.tryParse(item.findElements('pubDate').first.innerText) ?? DateTime.now(),
      source: "Google News",
    );
  }
}
