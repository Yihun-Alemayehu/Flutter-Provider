import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => BreadCrumbProvider(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/new': (context) => const NewBreadCrumbWidget(),
      },
    ),
  ));
}

class BreadCrumb {
  bool isActive;
  final String name;
  final String uuid;

  BreadCrumb({
    required this.isActive,
    required this.name,
  }) : uuid = const Uuid().v4();

  void activate() {
    isActive = true;
  }

  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  String get title => name + (isActive ? ' > ' : '');
}

class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];
  UnmodifiableListView<BreadCrumb> get item => UnmodifiableListView(_items);

  void add(BreadCrumb breadCrumb) {
    for (final item in _items) {
      item.activate();
    }

    _items.add(breadCrumb);
    notifyListeners();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}

typedef OnBreadCrumbTapped = void Function(BreadCrumb);

class BreadCrumbWidget extends StatelessWidget {
  final OnBreadCrumbTapped onTapped;
  final UnmodifiableListView<BreadCrumb> breadCrumbs;
  const BreadCrumbWidget({
    super.key,
    required this.breadCrumbs,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumbs.map(
        (breadCrumb) {
          return GestureDetector(
            onTap: () {
              onTapped(breadCrumb);
            },
            child: Text(
              breadCrumb.title,
              style: TextStyle(
                color: breadCrumb.isActive ? Colors.blue : Colors.black,
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Consumer<BreadCrumbProvider>(
            builder: (context, value, child) {
              return BreadCrumbWidget(
                  onTapped: (p0) {}, breadCrumbs: value.item);
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/new');
            },
            child: const Text('Add new bread crumb'),
          ),
          TextButton(
            onPressed: () {
              context.read<BreadCrumbProvider>().reset();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class NewBreadCrumbWidget extends StatefulWidget {
  const NewBreadCrumbWidget({super.key});

  @override
  State<NewBreadCrumbWidget> createState() => _NewBreadCrumbWidgetState();
}

class _NewBreadCrumbWidgetState extends State<NewBreadCrumbWidget> {
  late final TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new bread crumb'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
                hintText: 'Enter a new bread crumb here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
          ),
          TextButton(
              onPressed: () {
                final text = controller.text;
                if (text.isNotEmpty) {
                  final breadCrumb = BreadCrumb(
                    isActive: false,
                    name: text,
                  );
                  context.read<BreadCrumbProvider>().add(breadCrumb);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'))
        ],
      ),
    );
  }
}
