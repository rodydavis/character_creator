// Copyright 2024 the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/link.dart';

void main() {
  runApp(const GenerativeAISample());
}

class GenerativeAISample extends StatelessWidget {
  const GenerativeAISample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Character Generator',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const ChatScreen(title: 'Character Generator'),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.title});

  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? apiKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: switch (apiKey) {
        final providedKey? => ChatWidget(apiKey: providedKey),
        _ => ApiKeyWidget(onSubmitted: (key) {
            setState(() => apiKey = key);
          }),
      },
    );
  }
}

class ApiKeyWidget extends StatelessWidget {
  ApiKeyWidget({required this.onSubmitted, super.key});

  final ValueChanged onSubmitted;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'To use the Gemini API, you\'ll need an API key. '
              'If you don\'t already have one, '
              'create a key in Google AI Studio.',
            ),
            const SizedBox(height: 8),
            Link(
              uri: Uri.https('aistudio.google.com', '/app/apikey'),
              target: LinkTarget.blank,
              builder: (context, followLink) => TextButton(
                onPressed: followLink,
                child: const Text('Get an API Key'),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration:
                          textFieldDecoration(context, 'Enter your API key'),
                      controller: _textController,
                      onSubmitted: (value) {
                        onSubmitted(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      onSubmitted(_textController.value.text);
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({required this.apiKey, super.key});

  final String apiKey;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  Future<Character>? characterResponse;
  late final CharacterService service;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    service = CharacterService(widget.apiKey);
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Blah, blah'),
          const SizedBox(height: 32),
          Text('Name', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: textFieldDecoration(
              context,
              'Give your character a name',
            ),
          ),
          const SizedBox(height: 16),
          Text('Description', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 5,
            minLines: 5,
            decoration: textFieldDecoration(
              context,
              'Describe your character in a few sentences.',
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              child: const Text('Generate!'),
              onPressed: () {
                setState(() {
                  characterResponse = service.generateCharacter(
                      nameController.text, descriptionController.text);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterDisplay(BuildContext context, Character character) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(),
              ),
              width: 300,
              height: 150,
              child: const Placeholder(),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            character.name,
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 32),
          Text(
            'Appearance',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Age: ${character.appearance.age}',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Height: ${character.appearance.height}',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Weight: ${character.appearance.weight}',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Build: ${character.appearance.build}',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Hair: ${character.appearance.hair}',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Eyes: ${character.appearance.eyes}',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Clothing',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            character.clothing,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Accessories',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            character.accessories,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Personality',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            character.personality,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Role',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            character.roleInGame,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  characterResponse = null;
                });
              },
              child: const Text('Create Another'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(BuildContext context) {
    return const Center(child: Text('Error'));
  }

  Widget _buildThinkingIndicator(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SingleChildScrollView(
        child: (characterResponse == null)
            ? _buildForm(context)
            : FutureBuilder(
                future: characterResponse,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _buildCharacterDisplay(context, snapshot.data!);
                  } else if (snapshot.hasError) {
                    return _buildErrorDisplay(context);
                  }

                  return _buildThinkingIndicator(context);
                },
              ),
      ),
    );
  }
}

InputDecoration textFieldDecoration(BuildContext context, String hintText) =>
    InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );

class CharacterService {
  final String apiKey;

  late final GenerativeModel model;

  final generationConfig = GenerationConfig(
    temperature: 0.4,
    topK: 32,
    topP: 1,
    maxOutputTokens: 4096,
  );

  final safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
  ];

  CharacterService(this.apiKey) {
    model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  }

  Future<Character> generateCharacter(String name, String description) async {
    final prompt = [
      Content.multi([
        TextPart(nameExample1),
        TextPart(descriptionExample1),
        TextPart(responseExample1),
        TextPart(nameExample2),
        TextPart(descriptionExample2),
        TextPart(responseExample2),
        TextPart(name),
        TextPart(description),
      ]),
    ];

    try {
      final response = await model.generateContent(
        prompt,
        safetySettings: safetySettings,
        generationConfig: generationConfig,
      );

      debugPrint(response.text);

      final json = jsonDecode(response.text!);
      final character = Character.fromJson(json);
      return character;
    } catch (ex) {
      debugPrint(ex.toString());
      throw 'Whoops!';
    }

    // return Future.delayed(
    //   const Duration(seconds: 2),
    //   () => const Character(
    //     name: 'Andrew',
    //     appearance: Appearance(
    //       age: '47',
    //       height: '6\'1"',
    //       weight: '200',
    //       build: 'Thick',
    //       eyes: 'Hazel',
    //       hair: 'Red as the sunset, baby',
    //     ),
    //     clothing: 'T-shirt and cargo shorts',
    //     personality: 'Utterly hilarious',
    //     accessories: 'Why would this fine specimen need accessorizing?',
    //     roleInGame: 'He\'s a lovable scamp',
    //   ),
    // );
  }
}

class Appearance {
  final String age;
  final String height;
  final String weight;
  final String build;
  final String hair;
  final String eyes;

  const Appearance({
    required this.age,
    required this.height,
    required this.weight,
    required this.build,
    required this.hair,
    required this.eyes,
  });

  Appearance.fromJson(Map<String, dynamic> json)
      : age = json['age'] ?? '',
        height = json['height'] ?? '',
        weight = json['weight'] ?? '',
        build = json['build'] ?? '',
        hair = json['hair'] ?? '',
        eyes = json['eyes'] ?? '';
}

class Character {
  final String name;
  final Appearance appearance;
  final String clothing;
  final String accessories;
  final String personality;
  final String roleInGame;

  const Character({
    required this.name,
    required this.appearance,
    required this.clothing,
    required this.accessories,
    required this.personality,
    required this.roleInGame,
  });

  Character.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        appearance = Appearance.fromJson(json['appearance']),
        clothing = json['clothing'] ?? '',
        accessories = json['accessories'] ?? '',
        personality = json['personality'] ?? '',
        roleInGame = json['roleInGame'] ?? '';
}

const nameExample1 = '''
Elara
''';

const descriptionExample1 = '''
The Village Herbalist
''';

const responseExample1 = '''
{
  "name": "Elara",
  "appearance": {
    "age": "Mid-50s, with laugh lines around her eyes and streaks of grey in her warm brown hair, often braided and adorned with wildflowers.",
    "height": "5'11\\"",
    "weight": "155",
    "build": "Slender yet strong from years of tending her garden and foraging in the nearby woods.",
    "hair": "Silver, like the moon.",
    "eyes": "Blue, like the sea."
  },
  "clothing": "Elara prefers practical, earth-toned garments made from natural fabrics like linen and wool.  She often wears a long, flowy skirt, a fitted bodice, and a shawl or apron with pockets overflowing with seeds, dried herbs, and small tools.",
  "accessories": "Always barefoot with dirt under her fingernails. Her hands often bear the green stains of crushed leaves and berries.  A simple leather cord necklace with a polished river stone pendant hangs around her neck.",
  "personality": "Elara possesses a deep love for all living things and is always willing to lend a hand or offer a calming word. Years of studying the natural world have granted her extensive knowledge of plants, their medicinal properties, and the delicate balance of the ecosystem. Elara is self-sufficient and comfortable living a simple life close to nature.  She is a skilled herbalist, gardener, and forager, able to utilize the gifts of the land to provide for herself and others. She feels a strong connection to the earth and the magical energy that flows through it.  She often incorporates folklore and ancient rituals into her herbal practice.",
  "roleInGame": "Players can visit Elara to purchase healing remedies, salves, and teas crafted from her garden. Elara may ask the player to help her gather rare herbs, protect sacred natural sites, or even assist with local wildlife. Through conversations, she reveals snippets of local history, folklore, and wisdom about the interconnectedness of all things. Elara's gentle wisdom and deep connection to nature can offer the player guidance and perspective when making difficult choices."
}
''';

const nameExample2 = '''
Lark
''';

const descriptionExample2 = '''
The Wandering Bard
''';

const responseExample2 = '''
{
  "name": "Lark",
  "appearance": {
    "age": "Early 20s, with a youthful appearance and a mischievous twinkle in their eyes.",
    "height": "5'11\\"",
    "weight": "155",
    "build": "Lark has a lithe and agile frame, well-suited to their nomadic lifestyle.",
    "hair": "Silver, like the moon.",
    "eyes": "Blue, like the sea."
  },
  "clothing": "They favor comfortable and practical attire, often layered and mismatched, reflecting the various places they've visited. Think loose trousers, a tunic, a colorful scarf, and a well-worn cloak adorned with trinkets and charms gathered from their travels.",
  "accessories": "Lark always carries their trusty lute, often decorated with carvings and colorful ribbons. They might have an assortment of small instruments tucked into their belt, such as a flute or a set of panpipes.  Their ears may be adorned with several earrings, and their fingers with rings collected from different regions.",
  "personality": "Lark is a restless soul, always seeking new experiences and stories to tell.  They have a deep love for travel and a thirst for knowledge about the world and its diverse cultures. Music is Lark's lifeblood, and they possess a natural talent for playing instruments and composing songs. Their performances are often infused with a touch of magic, reflecting the emotions and tales woven into their music. Lark is a gifted storyteller with a knack for captivating their audience.  They can easily make friends wherever they go and have a talent for bringing people together. Through their travels, Lark has developed a keen understanding of human nature and the interconnectedness of the world. They can offer unique perspectives and hidden truths through their songs and stories.",
  "roleInGame": "Lark wanders the realm, sharing their music and stories with the villages and towns they pass through. Players might encounter them performing in taverns, market squares, or even around a campfire in the wilderness. Lark's travels may lead them to uncover secrets or discover places of interest. They could offer quests to the player that involve retrieving a lost instrument, composing a song for a specific purpose, or helping a community in need. Lark's songs and tales offer glimpses into the broader world beyond the player's immediate surroundings. They may share news of distant lands, historical events, or even rumors of mythical creatures and hidden treasures. Lark's free spirit and optimistic outlook can offer encouragement and a fresh perspective to the player.  Their music might even have magical qualities, providing buffs or enhancing abilities."
}
''';
