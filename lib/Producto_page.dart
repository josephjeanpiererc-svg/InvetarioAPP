import 'package:flutter/material.dart';
import 'package:inventarioapp/models/Producto.dart';

class ProductoPage extends StatefulWidget {
  final List<Producto> productos;

  const ProductoPage({Key? key, required this.productos}) : super(key: key);

  @override
  State<ProductoPage> createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  late List<Producto> productos;

  @override
  void initState() {
    super.initState();
    productos = widget.productos;
  }

  void agregarProducto(Producto producto) {
    setState(() {
      productos.add(producto);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Productos registrados (${productos.length})'),
      ),
      body: productos.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No hay productos registrados',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Código')),
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Categoría')),
                    DataColumn(label: Text('Precio')),
                    DataColumn(label: Text('Stock')),
                    DataColumn(label: Text('Estado')),
                    DataColumn(label: Text('Fecha de ingreso')),
                    DataColumn(label: Text('Perecible')),
                  ],
                  rows: productos.map((producto) {
                    return DataRow(
                      cells: [
                        DataCell(Text(producto.codigo)),
                        DataCell(Text(producto.nombre)),
                        DataCell(Text(producto.categoria)),
                        DataCell(
                          Text('S/ ${producto.precio.toStringAsFixed(2)}'),
                        ),
                        DataCell(Text('${producto.stock}')),
                        DataCell(Text(producto.estado)),
                        DataCell(Text(producto.fechaIngresoTexto)),
                        DataCell(Text(producto.perecible ? 'Sí' : 'No')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
