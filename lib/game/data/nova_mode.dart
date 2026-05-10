enum NovaMode {
  laser,
  dreadnought,
  voidTyrant,
  leviathan,
  bloodColossus,
  stormPhantom,
  cosmicBehemoth,
  shadowReaper,
  solarTitan,
  voidEmperor,
  singularity;

  String get displayName => switch (this) {
        NovaMode.laser          => 'Pulse Burst',
        NovaMode.dreadnought    => 'Abomination Strike',
        NovaMode.voidTyrant     => 'Plague Pulse',
        NovaMode.leviathan      => 'Gore Wave',
        NovaMode.bloodColossus  => 'Blood Barrage',
        NovaMode.stormPhantom   => 'Feral Cross',
        NovaMode.cosmicBehemoth => 'Toxic Tide',
        NovaMode.shadowReaper   => 'Wraith Streams',
        NovaMode.solarTitan     => 'Rot Rings',
        NovaMode.voidEmperor    => 'Infection Surge',
        NovaMode.singularity    => 'Horde Eruption',
      };

  String get inheritTitle => switch (this) {
        NovaMode.laser          => 'Standard Blitz',
        NovaMode.dreadnought    => 'Inherit ABOMINATION STRIKE',
        NovaMode.voidTyrant     => 'Inherit PLAGUE PULSE',
        NovaMode.leviathan      => 'Inherit GORE WAVE',
        NovaMode.bloodColossus  => 'Inherit BLOOD BARRAGE',
        NovaMode.stormPhantom   => 'Inherit FERAL CROSS',
        NovaMode.cosmicBehemoth => 'Inherit TOXIC TIDE',
        NovaMode.shadowReaper   => 'Inherit WRAITH STREAMS',
        NovaMode.solarTitan     => 'Inherit ROT RINGS',
        NovaMode.voidEmperor    => 'Inherit INFECTION SURGE',
        NovaMode.singularity    => 'Inherit HORDE ERUPTION',
      };

  String get inheritDescription => switch (this) {
        NovaMode.laser          => 'Forward energy burst',
        NovaMode.dreadnought    => 'Fires 12 radial shots in all directions',
        NovaMode.voidTyrant     => 'Fires 16 plague spores in all directions',
        NovaMode.leviathan      => 'Fires 24 gore bolts radially',
        NovaMode.bloodColossus  => 'Fires 24 crimson blood bolts',
        NovaMode.stormPhantom   => 'Fires X-pattern feral claw burst',
        NovaMode.cosmicBehemoth => 'Fires 32 toxic radial shots',
        NovaMode.shadowReaper   => 'Fires twin forward/backward dark streams',
        NovaMode.solarTitan     => 'Fires dual rot rings outward',
        NovaMode.voidEmperor    => 'Fires 28 infection bolts at high speed',
        NovaMode.singularity    => 'Fires 40 white radial shots',
      };
}
