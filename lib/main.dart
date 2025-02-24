import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() {
  setupWindow();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AgeCounter(),
      child: const MyApp(),
    ),
  );
}

const double windowWidth = 720;
const double windowHeight = 1280;

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Age Counter');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(Rect.fromCenter(
        center: screen!.frame.center,
        width: windowWidth,
        height: windowHeight,
      ));
    });
  }
}

class AgeCounter with ChangeNotifier {
  int age = 0;
  String _currentLifeStage = 'Childhood';

  void increment(BuildContext context) {
    age += 1;
    _checkMilestone(context);
    notifyListeners();
  }

  void decrement(BuildContext context) {
    if (age > 0) {
      age -= 1;
      _checkMilestone(context);
      notifyListeners();
    }
  }

  String getLifeStage() {
    if (age >= 0 && age <= 12) {
      return 'Childhood';
    } else if (age >= 13 && age <= 19) {
      return 'Teenage';
    } else if (age >= 20 && age <= 30) {
      return 'Young Adult';
    } else if (age >= 31 && age <= 50) {
      return 'Adult';
    } else {
      return 'Senior';
    }
  }

  Color getBackgroundColor() {
    if (age >= 0 && age <= 12) {
      return Colors.lightBlue;
    } else if (age >= 13 && age <= 19) {
      return Colors.lightGreen;
    } else if (age >= 20 && age <= 30) {
      return const Color.fromARGB(255, 251, 245, 190);
    } else if (age >= 31 && age <= 50) {
      return Colors.orange.shade200;
    } else {
      return Colors.grey.shade400;
    }
  }

  void _checkMilestone(BuildContext context) {
    String newLifeStage = getLifeStage();
    if (newLifeStage != _currentLifeStage) {
      _currentLifeStage = newLifeStage;
      _showMilestonePopup(context, newLifeStage);
    }
  }

  void _showMilestonePopup(BuildContext context, String lifeStage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Milestone reached: $lifeStage'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void updateAgeFromSlider(double newAge, BuildContext context) {
    age = newAge.toInt();
    _checkMilestone(context);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Age Counter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var ageCounter = context.watch<AgeCounter>();
    var backgroundColor = ageCounter.getBackgroundColor();
    var lifeStage = ageCounter.getLifeStage();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Age Counter with Milestones'),
      ),
      body: Container(
        color: backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('I am ${ageCounter.age} years old'),
              const SizedBox(height: 10),
              Text(
                'Life Stage: $lifeStage',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Slider(
                value: ageCounter.age.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                label: '${ageCounter.age}',
                onChanged: (double newAge) {
                  ageCounter.updateAgeFromSlider(newAge, context);
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      context.read<AgeCounter>().decrement(context);
                    },
                    tooltip: 'Decrement',
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    onPressed: () {
                      context.read<AgeCounter>().increment(context);
                    },
                    tooltip: 'Increment',
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
