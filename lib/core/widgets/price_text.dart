import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class PriceText extends StatefulWidget {
  final double price;
  final TextStyle? style;
  final TextAlign? textAlign;

  const PriceText({
    super.key,
    required this.price,
    this.style,
    this.textAlign,
  });

  @override
  State<PriceText> createState() => _PriceTextState();
}

class _PriceTextState extends State<PriceText> {
  String _formattedPrice = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFormattedPrice();
  }

  @override
  void didUpdateWidget(PriceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.price != widget.price) {
      _loadFormattedPrice();
    }
  }

  Future<void> _loadFormattedPrice() async {
    try {
      final formatted = await Formatters.formatPrice(widget.price);
      if (mounted) {
        setState(() {
          _formattedPrice = formatted;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _formattedPrice = Formatters.formatPriceSync(widget.price);
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: 60,
        height: 16,
        child: LinearProgressIndicator(
          backgroundColor: Colors.grey[300],
        ),
      );
    }

    return Text(
      _formattedPrice,
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}

// Helper widget for building price text with currency symbol
class PriceBuilder extends StatelessWidget {
  final double price;
  final Widget Function(String formattedPrice) builder;

  const PriceBuilder({
    super.key,
    required this.price,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Formatters.formatPrice(price),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return builder(snapshot.data!);
        } else if (snapshot.hasError) {
          return builder(Formatters.formatPriceSync(price));
        } else {
          return SizedBox(
            width: 60,
            height: 16,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[300],
            ),
          );
        }
      },
    );
  }
}
