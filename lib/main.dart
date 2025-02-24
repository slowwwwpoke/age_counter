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
    // Using ChangeNotifierProvider to rebuild widgets when the model changes.
    ChangeNotifierProvider(
      // Initialize AgeCounter model here to let Provider manage its lifecycle.
      create: (context) => AgeCounter(),
      child: const MyApp(),
    ),
  );
}

// Define fixed window size for desktop
const double windowWidth = 360;
const double windowHeight = 640;

// Setup window size and position for desktop platforms
void setupWindow() {
  // Check if the platform is desktop but not web
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Age Counter');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    // Center the window on the screen
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
/// The AgeCounter model keeps track of the user's age.
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
}

/// Root widget of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Age Counter',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Age Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the label for age
            const Text('Your age is:'),
            // Consumer listens to AgeCounter and rebuilds when age changes
            Consumer<AgeCounter>(
              builder: (context, counter, child) => Text(
                '${counter.age}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
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
    );
  }
}
