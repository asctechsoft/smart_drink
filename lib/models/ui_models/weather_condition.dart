enum WeatherCondition {
  normal('normal', '18 – 25°C', 0),
  cold('cold', '< 18°C', 250),
  warm('warm', '26 – 30°C', 300),
  hot('hot', '> 30°C', 600);

  final String label;
  final String description;
  final int extraMl;

  const WeatherCondition(this.label, this.description, this.extraMl);
}

