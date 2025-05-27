import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class PredictionScreen extends StatelessWidget {
  final String imagePath;
  final String prediction;
  final double confidence;
  final Map<String, double> otherConfidences;

  const PredictionScreen({
    super.key,
    required this.imagePath,
    required this.prediction,
    required this.confidence,
    required this.otherConfidences,
  });

  final Map<String, String> _explanations = const {
    "Resistor":
        "This is a placeholder explanation about resistors. They are used to limit current and divide voltages in circuits. You can replace this with a more detailed description of what a resistor does in your own words or technical explanation.",
    "Capacitor":
        "This is a placeholder explanation about capacitors. Capacitors store and discharge electrical energy in a circuit. They are widely used in electronic filtering and timing circuits. You can replace this with more information specific to your app.",
    "Transistor":
        "This is a placeholder explanation about transistors. They function as switches or amplifiers in circuits. They are fundamental to all modern electronics. Replace this with your own explanation for your users.",
  };

  Future<void> _saveImage(BuildContext context) async {
    try {
      final Directory? dir = await getExternalStorageDirectory();
      if (dir == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text("Error: Storage not accessible")),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final String savePath = '${dir.path}/SavedImages';
      await Directory(savePath).create(recursive: true);

      String newImagePath =
          '$savePath/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await File(imagePath).copy(newImagePath);
      await Gal.putImage(newImagePath);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> savedImages = prefs.getStringList('saved_images') ?? [];

      // Store image path with label as JSON string
      Map<String, String> data = {
        "path": newImagePath,
        "label": prediction.toUpperCase(), // standardize for filtering
      };

      savedImages.add(data.toString());
      await prefs.setStringList('saved_images', savedImages);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text("Image saved to gallery")),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text("Error saving image: $e")),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String explanation =
        _explanations[prediction] ?? "No explanation available.";

    return Scaffold(
      appBar: AppBar(title: Text("Prediction Result"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.file(
                File(imagePath),
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20),
              Text(
                prediction,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Confidence: ${(confidence * 100).toStringAsFixed(2)}%",
                style: TextStyle(
                  fontSize: 18,
                  color: confidence < 0.6 ? Colors.red : Colors.green,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _saveImage(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text("Save to Gallery"),
              ),
              SizedBox(height: 30),
              Text(
                "Confidence Scores",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildPieChart(),
              SizedBox(height: 30),
              Text(
                "About the $prediction:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _ExpandableTextSection(explanation: explanation),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    List<PieChartSectionData> sections = [];

    sections.add(
      PieChartSectionData(
        value: confidence,
        title: "${(confidence * 100).toStringAsFixed(1)}%",
        color: _getColorForLabel(prediction),
        radius: 50,
      ),
    );

    sections.addAll(
      otherConfidences.entries.map((entry) {
        return PieChartSectionData(
          value: entry.value,
          title: "${(entry.value * 100).toStringAsFixed(1)}%",
          color: _getColorForLabel(entry.key),
          radius: 50,
        );
      }).toList(),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 250,
          width: 250,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        SizedBox(width: 20),
        _buildLegend(),
      ],
    );
  }

  Color _getColorForLabel(String label) {
    final colors = {
      "Resistor": Colors.blue,
      "Capacitor": Colors.green,
      "Transistor": Colors.orange,
    };
    return colors[label] ?? Colors.grey;
  }

  Widget _buildLegend() {
    List<Widget> legendItems = [
      _buildLegendItem(prediction, _getColorForLabel(prediction)),
    ];
    otherConfidences.forEach((key, value) {
      legendItems.add(_buildLegendItem(key, _getColorForLabel(key)));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: legendItems,
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 20, height: 20, color: color),
        SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}

class _ExpandableTextSection extends StatefulWidget {
  final String explanation;
  const _ExpandableTextSection({required this.explanation});

  @override
  State<_ExpandableTextSection> createState() => _ExpandableTextSectionState();
}

class _ExpandableTextSectionState extends State<_ExpandableTextSection> {
  bool showFull = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            widget.explanation,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16),
          ),
          secondChild: Text(widget.explanation, style: TextStyle(fontSize: 16)),
          crossFadeState:
              showFull ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: Duration(milliseconds: 200),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              showFull = !showFull;
            });
          },
          child: Text(showFull ? "Show less" : "Read more"),
        ),
      ],
    );
  }
}
