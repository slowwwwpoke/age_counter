import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() {
  // Set up the window size for desktop platforms
  setupWindow();
  runApp(
    // Provide the AgeCounter model to all widgets within the app.
    ChangeNotifierProvider(
      create: (context) => AgeCounter(),
      child: const MyApp(),
    ),
  );
}

// Define fixed window size for desktop
const double windowWidth = 720;
const double windowHeight = 1280;

// Setup window size and position for desktop platforms
void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Age Counter with Milestones');
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

/// Model to manage age state
///
/// [ChangeNotifier] is used to notify listeners when the state changes.
/// The AgeCounter model keeps track of the user's age and determines the life stage.
class AgeCounter with ChangeNotifier {
  int age = 0; // Initialize age to 0

  // Increment age by 1 and notify listeners to rebuild widgets
  void increment() {
    age += 1;
    notifyListeners();
  }

  // Decrement age by 1 but ensure it doesn't go below 0
  void decrement() {
    if (age > 0) {
      age -= 1;
      notifyListeners();
    }
  }

  // Determine life stage based on age
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

  // Determine background color based on life stage
  Color getBackgroundColor() {
    if (age >= 0 && age <= 12) {
      return Colors.yellow.shade200;
    } else if (age >= 13 && age <= 19) {
      return Colors.blue.shade200;
    } else if (age >= 20 && age <= 30) {
      return Colors.green.shade200;
    } else if (age >= 31 && age <= 50) {
      return Colors.orange.shade200;
    } else {
      return Colors.grey.shade400;
    }
  }
}

/// Root widget of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Age Counter with Milestones',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Use Material Design 3
      ),
      home: const MyHomePage(), // Main screen of the app
    );
  }
}

/// Main screen widget
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the AgeCounter model to get the life stage and background color
    var ageCounter = context.watch<AgeCounter>();
    var backgroundColor = ageCounter.getBackgroundColor();
    var lifeStage = ageCounter.getLifeStage();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Age Counter with Milestones'),
      ),
      // Change background color based on life stage
      body: Container(
        color: backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the label for age
              const Text('Your age is:'),
              // Display the current age
              Text(
                '${ageCounter.age}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              // Display the corresponding life stage
              Text(
                'Life Stage: $lifeStage',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20), // Add some spacing
              // Row to display increment and decrement buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Button to decrement age
                  FloatingActionButton(
                    onPressed: () {
                      // Use context.read() to access AgeCounter outside of build
                      context.read<AgeCounter>().decrement();
                    },
                    tooltip: 'Decrement', // Tooltip for accessibility
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 20), // Space between buttons
                  // Button to increment age
                  FloatingActionButton(
                    onPressed: () {
                      context.read<AgeCounter>().increment();
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
