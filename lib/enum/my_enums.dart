enum FiberType {
  cotton('Cotton'),
  wool('Wool'),
  silk('Silk'),
  linen('Linen'),
  synthetic('Synthetic'),
  mixed('Mixed');

  const FiberType(this.label);
  final String label;
}

enum LoomApplicationClass {
  handLoomFly('Hand-Loom Fly'),
  northropAutomatic('Northrop Automatic'),
  draperBoxLoom('Draper Box Loom'),
  silkRibbonNarrow('Silk Ribbon Narrow-Fabric Frame'),
  powerLoomFly('Power-Loom Fly'),
  skiShuttleFrame('Ski-Shuttle Frame');

  const LoomApplicationClass(this.label);
  final String label;
}

enum ArtisanHallmark {
  bedfordLoom('Bedford Loom Shuttle Guild'),
  atlanticShuttlewood('Atlantic Shuttlewood & Eye'),
  highSpeedWeft('High-Speed Weft Supply'),
  lancasterEyeWorks('Lancaster Eye Works'),
  millRowTimber('Mill Row Timber Co.'),
  verdantPirn('Verdant Pirn & Tip');

  const ArtisanHallmark(this.label);
  final String label;
}

enum ThreadDeliveryEyelet {
  glazedPorcelain('Glazed porcelain ring'),
  brassTensionCoil('Brass tension coil'),
  slottedCastIron('Slotted cast-iron block'),
  steelEyeRing('Hardened steel eye ring'),
  ceramicBushing('Ceramic bushing insert'),
  notApplicable('Not applicable');

  const ThreadDeliveryEyelet(this.label);
  final String label;
}

enum TimberHardwood {
  seasonedPersimmon('Seasoned persimmon'),
  compressedDogwood('Compressed dogwood'),
  laminatedCornel('Laminated cornel wood'),
  beechBlock('Beech block'),
  lignumVitae('Lignum vitae'),
  mapleLaminate('Maple laminate');

  const TimberHardwood(this.label);
  final String label;
}

enum TipMetallurgy {
  hardenedToolSteel('Hardened tool steel rivets'),
  swagedCastIron('Swaged cast iron tips'),
  brassFerrule('Brass ferrule caps'),
  nickelSteelCap('Nickel steel nose caps'),
  wroughtIron('Wrought iron tip plates'),
  notTipped('No metal tips');

  const TipMetallurgy(this.label);
  final String label;
}

enum TrackFrictionWear {
  polishedWax('Polished wax finish'),
  lightTrackPolish('Light track polish'),
  splitGrainScoring('Split grain scoring'),
  splinteredHeel('Splintered heel'),
  noseCapDisplacement('Nose-cap displacement'),
  displayCased('Display-cased / museum hold');

  const TrackFrictionWear(this.label);
  final String label;
}
