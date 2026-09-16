import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Producto_page.dart';
import 'models/Producto.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Productos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
      ),
      home: const RegistroProductoPage(),
    );
  }
}

class RegistroProductoPage extends StatefulWidget {
  const RegistroProductoPage({super.key});

  @override
  State<RegistroProductoPage> createState() => _RegistroProductoPageState();
}

class _RegistroProductoPageState extends State<RegistroProductoPage> {
  static const String _productosKey = 'productos_registrados';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoCtrl = TextEditingController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _precioCtrl = TextEditingController();

  final List<Producto> _productos = <Producto>[];
  final List<String> _categorias = const [
    'Abarrotes',
    'Bebidas',
    'Limpieza',
    'Golosinas',
    'Lácteos',
    'Otro',
  ];
  final List<String> _estados = const ['Disponible', 'Agotado'];

  String? _categoria;
  String _estado = 'Disponible';
  DateTime? _fechaIngreso;
  double _stock = 0;
  bool _perecible = false;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    final prefs = await SharedPreferences.getInstance();
    final productosGuardados = prefs.getString(_productosKey);

    if (productosGuardados == null || productosGuardados.isEmpty) {
      return;
    }

    final decoded = jsonDecode(productosGuardados) as List;
    final productos = decoded
        .map(
          (item) => Producto.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();

    if (!mounted) return;
    setState(() {
      _productos
        ..clear()
        ..addAll(productos);
    });
  }

  Future<void> _guardarProductos() async {
    final prefs = await SharedPreferences.getInstance();
    final productosJson = jsonEncode(
      _productos.map((producto) => producto.toJson()).toList(),
    );
    await prefs.setString(_productosKey, productosJson);
  }

  Future<void> _seleccionarFechaIngreso() async {
    final DateTime hoy = DateTime.now();
    final DateTime? elegida = await showDatePicker(
      context: context,
      initialDate: _fechaIngreso ?? hoy,
      firstDate: DateTime(2000),
      lastDate: hoy,
      helpText: 'Selecciona la fecha de ingreso',
    );
    if (elegida != null) setState(() => _fechaIngreso = elegida);
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría.')),
      );
      return;
    }
    if (_fechaIngreso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la fecha de ingreso.')),
      );
      return;
    }

    final codigo = _codigoCtrl.text.trim();
    if (Producto.codigoDuplicado(_productos, codigo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ese código ya existe. Usa otro.')),
      );
      return;
    }

    final nuevoProducto = Producto(
      codigo: codigo,
      nombre: _nombreCtrl.text.trim(),
      categoria: _categoria!,
      precio: double.parse(_precioCtrl.text.replaceAll(',', '.')),
      stock: _stock.round(),
      estado: _estado,
      fechaIngreso: _fechaIngreso!,
      perecible: _perecible,
    );

    setState(() {
      _productos.add(nuevoProducto);
      _formKey.currentState!.reset();
      _codigoCtrl.clear();
      _nombreCtrl.clear();
      _precioCtrl.clear();
      _categoria = null;
      _estado = 'Disponible';
      _fechaIngreso = null;
      _stock = 0;
      _perecible = false;
    });

    await _guardarProductos();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Producto registrado (total: ${_productos.length})'),
      ),
    );
  }

  void _verProductos() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductoPage(productos: _productos)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Registro de Productos'),
        actions: [
          IconButton(
            tooltip: 'Ver productos',
            onPressed: _verProductos,
            icon: Badge(
              label: Text('${_productos.length}'),
              isLabelVisible: _productos.isNotEmpty,
              child: const Icon(Icons.table_rows),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _codigoCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Código del producto',
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el código';
                  }
                  if (value.length != 6) {
                    return 'Debe tener exactamente 6 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ingresa el nombre'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _categoria,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: _categorias
                    .map(
                      (categoria) => DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _categoria = value),
                validator: (value) =>
                    value == null ? 'Selecciona la categoría' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio unitario (S/)',
                ),
                validator: (value) {
                  final double? precio = double.tryParse(
                    value?.replaceAll(',', '.') ?? '',
                  );
                  return precio == null || precio <= 0
                      ? 'Ingresa un precio mayor que 0'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              Text('Cantidad en stock: ${_stock.round()}'),
              Slider(
                value: _stock,
                min: 0,
                max: 100,
                divisions: 100,
                label: _stock.round().toString(),
                onChanged: (value) => setState(() => _stock = value),
              ),
              const SizedBox(height: 8),
              const Text('Estado'),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: _estados
                    .map(
                      (estado) =>
                          ButtonSegment(value: estado, label: Text(estado)),
                    )
                    .toList(),
                selected: {_estado},
                onSelectionChanged: (value) =>
                    setState(() => _estado = value.first),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _fechaIngreso == null
                      ? 'Fecha de ingreso'
                      : 'Ingreso: ${_fechaIngreso!.day.toString().padLeft(2, '0')}/'
                            '${_fechaIngreso!.month.toString().padLeft(2, '0')}/${_fechaIngreso!.year}',
                ),
                onPressed: _seleccionarFechaIngreso,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('¿Producto perecible?'),
                value: _perecible,
                onChanged: (value) => setState(() => _perecible = value),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _registrar,
                icon: const Icon(Icons.inventory_2),
                label: const Text('Registrar producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
