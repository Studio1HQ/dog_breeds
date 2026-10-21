import 'package:dog_breeds/screens/dog_breed_screen.dart';
import 'package:flutter/material.dart';
import 'package:measure_flutter/measure_flutter.dart';

Future<void> main() async {
  await Measure.instance.init(
    () => runApp(MeasureWidget(child: const MyApp())),
    config: const MeasureConfig(),
  );
  // Future.delayed(const Duration(seconds: 2), () {
  //   throw Exception('Test crash from Measure');
  // });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dog Breed Explorer',
      theme: ThemeData(
        useMaterial3: true,
        
        scaffoldBackgroundColor: const Color(0xFFFAFAF7),
      ),
      home: const DogBreedScreen(),
      );
  }
}
