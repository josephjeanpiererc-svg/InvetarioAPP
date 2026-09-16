class Producto {
  final String codigo;
  final String nombre;
  final String categoria;
  final double precio;
  final int stock;
  final String estado;
  final DateTime fechaIngreso;
  final bool perecible;

  const Producto({
    required this.codigo,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.stock,
    required this.estado,
    required this.fechaIngreso,
    required this.perecible,
  });

  static bool codigoDuplicado(List<Producto> productos, String codigo) {
    final codigoNormalizado = codigo.trim();
    return productos.any((producto) => producto.codigo == codigoNormalizado);
  }

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      categoria: json['categoria'] as String,
      precio: (json['precio'] as num).toDouble(),
      stock: json['stock'] as int,
      estado: json['estado'] as String,
      fechaIngreso: DateTime.parse(json['fechaIngreso'] as String),
      perecible: json['perecible'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'categoria': categoria,
      'precio': precio,
      'stock': stock,
      'estado': estado,
      'fechaIngreso': fechaIngreso.toIso8601String(),
      'perecible': perecible,
    };
  }

  String get fechaIngresoTexto {
    final String dia = fechaIngreso.day.toString().padLeft(2, '0');
    final String mes = fechaIngreso.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fechaIngreso.year}';
  }
}
