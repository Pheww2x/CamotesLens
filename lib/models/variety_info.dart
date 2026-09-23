class VarietyInfo {
  const VarietyInfo({
    required this.name,
    required this.leafCharacteristics,
    required this.commonUses,
    required this.growingInformation,
    required this.identifyingCharacteristics,
  });

  final String name;
  final String leafCharacteristics;
  final String commonUses;
  final String growingInformation;
  final String identifyingCharacteristics;
}

const supportedVarieties = [
  VarietyInfo(
    name: 'NSIC SP-37',
    leafCharacteristics:
        'Green, heart-shaped leaves with a clear central vein.',
    commonUses: 'Fresh root production and household food preparation.',
    growingInformation:
        'Performs well in warm climates with regular moisture and loose soil.',
    identifyingCharacteristics:
        'Vigorous vines and a distinct pointed leaf tip.',
  ),
  VarietyInfo(
    name: 'STOKE PURPLE',
    leafCharacteristics:
        'Broad green leaves with shallow lobing and smooth margins.',
    commonUses: 'Root crops and young leaf vegetable preparation.',
    growingInformation:
        'Suitable for sunny plots with good drainage and moderate fertility.',
    identifyingCharacteristics: 'Broad blade and relatively short petiole.',
  ),
  VarietyInfo(
    name: 'VSP-7 (V20-429)',
    leafCharacteristics: 'Medium-sized leaves with gently angular lobes.',
    commonUses: 'Root crop production and local food processing.',
    growingInformation:
        'Benefits from weed-free beds and consistent early-season watering.',
    identifyingCharacteristics: 'Angular outline and visible branching veins.',
  ),
  VarietyInfo(
    name: 'VSp-6 (V20-209)',
    leafCharacteristics:
        'Deep green, slightly lobed leaves with a firm texture.',
    commonUses: 'Root crop production and culinary use.',
    growingInformation:
        'Grows best in warm, well-lit areas with soil that does not stay waterlogged.',
    identifyingCharacteristics: 'Firm leaf blade and pronounced vein network.',
  ),
];
