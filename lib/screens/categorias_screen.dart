import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/categoria.dart';
import '../services/categoria_service.dart';
import '../services/api_service.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({
    super.key,
  });

  @override
  State<CategoriasScreen> createState() =>
      _CategoriasScreenState();
}

class _CategoriasScreenState
    extends State<CategoriasScreen> {
  List<Categoria> categorias = [];

  bool cargando = true;

  String busqueda = '';

  // ============================================================
  // PERMISOS SEGÚN ROL
  // ============================================================

  bool get esAdministrador {
    return ApiService.esAdministrador;
  }

  // ============================================================
  // COLORES
  // ============================================================

  static const Color azul =
      Color(0xFF1565C0);

  static const Color azulOscuro =
      Color(0xFF0D47A1);

  static const Color fondo =
      Color(0xFFF4F7FB);

  static const Color borde =
      Color(0xFFD9E0E8);

  static const Color texto =
      Color(0xFF172B4D);

  static const Color textoSecundario =
      Color(0xFF6B778C);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    cargarCategorias();
  }

  // ============================================================
  // CARGAR CATEGORÍAS
  // ============================================================

  Future<void> cargarCategorias() async {
    if (mounted) {
      setState(() {
        cargando = true;
      });
    }

    try {
      final resultado =
          await CategoriaService.obtenerCategorias();

      if (!mounted) return;

      setState(() {
        categorias = resultado;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No se pudieron cargar las categorías',
                ),
              ),
            ],
          ),
          backgroundColor:
              Colors.red.shade700,
          behavior:
              SnackBarBehavior.floating,
          margin:
              const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ============================================================
  // CATEGORÍAS FILTRADAS
  // ============================================================

  List<Categoria> get categoriasFiltradas {
    final textoBusqueda =
        busqueda.trim().toLowerCase();

    if (textoBusqueda.isEmpty) {
      return categorias;
    }

    return categorias.where((categoria) {
      return categoria.nombre
          .toLowerCase()
          .contains(textoBusqueda);
    }).toList();
  }

  // ============================================================
  // NUEVA CATEGORÍA
  // ============================================================

  Future<void> nuevaCategoria() async {
    if (!esAdministrador) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No tienes permisos para crear categorías.',
          ),
        ),
      );

      return;
    }

    final resultado =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _CategoriaDialog(
          esAdministrador:
              esAdministrador,
        );
      },
    );

    if (resultado == true) {
      await cargarCategorias();
    }
  }

  // ============================================================
  // EDITAR CATEGORÍA
  // ============================================================

  Future<void> editarCategoria(
    Categoria categoria,
  ) async {
    if (!esAdministrador) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No tienes permisos para modificar categorías.',
          ),
        ),
      );

      return;
    }

    final resultado =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _CategoriaDialog(
          categoria: categoria,
          esAdministrador:
              esAdministrador,
        );
      },
    );

    if (resultado == true) {
      await cargarCategorias();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            Colors.white,
        foregroundColor:
            texto,
        elevation: 0,
        surfaceTintColor:
            Colors.white,

        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration:
                  BoxDecoration(
                color:
                    azul.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  11,
                ),
              ),
              child: const Icon(
                Icons.category_outlined,
                color: azul,
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            const Text(
              'Categorías',
              style: TextStyle(
                color: texto,
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip:
                'Actualizar',
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            onPressed:
                cargando
                    ? null
                    : cargarCategorias,
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ========================================================
      // BOTÓN NUEVA CATEGORÍA
      // SOLO ADMINISTRADOR
      // ========================================================

      floatingActionButton:
          esAdministrador
              ? FloatingActionButton.extended(
                  onPressed:
                      cargando
                          ? null
                          : nuevaCategoria,
                  backgroundColor:
                      azul,
                  foregroundColor:
                      Colors.white,
                  elevation: 4,
                  icon: const Icon(
                    Icons.add_rounded,
                  ),
                  label:
                      const Text(
                    'Nueva categoría',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                )
              : null,

      // ========================================================
      // BODY
      // ========================================================

      body: cargando
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: azul,
              ),
            )
          : RefreshIndicator(
              color: azul,
              onRefresh:
                  cargarCategorias,
              child:
                  _contenido(),
            ),
    );
  }

  // ============================================================
  // CONTENIDO
  // ============================================================

  Widget _contenido() {
    if (categorias.isEmpty) {
      return _EstadoVacio(
        puedeCrear:
            esAdministrador,
        onCrear:
            nuevaCategoria,
      );
    }

    final lista =
        categoriasFiltradas;

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      padding:
          const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        100,
      ),

      children: [
        // ========================================================
        // ENCABEZADO
        // ========================================================

        Container(
          padding:
              const EdgeInsets.all(22),

          decoration:
              BoxDecoration(
            gradient:
                const LinearGradient(
              colors: [
                azul,
                azulOscuro,
              ],
              begin:
                  Alignment.topLeft,
              end:
                  Alignment.bottomRight,
            ),
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    azul.withValues(
                  alpha: 0.20,
                ),
                blurRadius: 18,
                offset:
                    const Offset(
                  0,
                  8,
                ),
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.15,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    17,
                  ),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color:
                      Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'Categorías de productos',
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      '${categorias.length} categoría${categorias.length == 1 ? '' : 's'} registrada${categorias.length == 1 ? '' : 's'}',
                      style:
                          const TextStyle(
                        color:
                            Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        // ========================================================
        // BUSCADOR
        // ========================================================

        Container(
          decoration:
              BoxDecoration(
            color:
                Colors.white,
            borderRadius:
                BorderRadius.circular(
              15,
            ),
            border:
                Border.all(
              color: borde,
            ),
          ),

          child: TextField(
            onChanged:
                (valor) {
              setState(() {
                busqueda =
                    valor;
              });
            },

            decoration:
                InputDecoration(
              hintText:
                  'Buscar categoría...',

              hintStyle:
                  const TextStyle(
                color:
                    textoSecundario,
              ),

              prefixIcon:
                  const Icon(
                Icons.search_rounded,
                color: azul,
              ),

              suffixIcon:
                  busqueda.isNotEmpty
                      ? IconButton(
                          icon:
                              const Icon(
                            Icons
                                .clear_rounded,
                          ),
                          onPressed:
                              () {
                            setState(() {
                              busqueda =
                                  '';
                            });
                          },
                        )
                      : null,

              border:
                  InputBorder.none,

              contentPadding:
                  const EdgeInsets
                      .symmetric(
                horizontal:
                    16,
                vertical:
                    15,
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        // ========================================================
        // CABECERA LISTA
        // ========================================================

        Row(
          children: [
            const Expanded(
              child: Text(
                'Lista de categorías',
                style:
                    TextStyle(
                  color: texto,
                  fontSize: 19,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 10,
                vertical: 6,
              ),

              decoration:
                  BoxDecoration(
                color:
                    azul.withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),

              child: Text(
                '${lista.length}',
                style:
                    const TextStyle(
                  color: azul,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        // ========================================================
        // RESULTADOS
        // ========================================================

        if (lista.isEmpty)
          const _SinResultados()
        else
          ...lista
              .asMap()
              .entries
              .map(
            (entry) {
              final index =
                  entry.key;

              final categoria =
                  entry.value;

              return _CategoriaCard(
                numero:
                    index + 1,

                categoria:
                    categoria,

                puedeEditar:
                    esAdministrador,

                onEditar:
                    () {
                  editarCategoria(
                    categoria,
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

// =================================================================
// TARJETA CATEGORÍA
// =================================================================

class _CategoriaCard
    extends StatelessWidget {
  final int numero;
  final Categoria categoria;
  final bool puedeEditar;
  final VoidCallback onEditar;

  const _CategoriaCard({
    required this.numero,
    required this.categoria,
    required this.puedeEditar,
    required this.onEditar,
  });

  static const Color azul =
      Color(0xFF1565C0);

  static const Color texto =
      Color(0xFF172B4D);

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFD9E0E8,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withValues(
              alpha: 0.035,
            ),
            blurRadius: 12,
            offset:
                const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child: InkWell(
        onTap:
            puedeEditar
                ? onEditar
                : null,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),

          child: Row(
            children: [
              // ==================================================
              // ICONO
              // ==================================================

              Container(
                width: 52,
                height: 52,

                decoration:
                    BoxDecoration(
                  color:
                      azul.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),

                child: const Icon(
                  Icons.category_rounded,
                  color: azul,
                  size: 26,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              // ==================================================
              // INFORMACIÓN
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      categoria.nombre,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,

                      style:
                          const TextStyle(
                        color: texto,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Row(
                      children: [
                        Icon(
                          categoria.activo
                              ? Icons
                                  .check_circle_outline
                              : Icons
                                  .pause_circle_outline,

                          size: 15,

                          color:
                              categoria.activo
                                  ? Colors
                                      .green
                                      .shade700
                                  : Colors
                                      .grey
                                      .shade600,
                        ),

                        const SizedBox(
                          width: 5,
                        ),

                        Text(
                          categoria.activo
                              ? 'Activa'
                              : 'Inactiva',

                          style:
                              TextStyle(
                            color:
                                categoria.activo
                                    ? Colors
                                        .green
                                        .shade700
                                    : Colors
                                        .grey
                                        .shade600,

                            fontSize: 12,

                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              // ==================================================
              // NUMERO
              // ==================================================

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      azul.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    9,
                  ),
                ),

                child: Text(
                  '#$numero',

                  style:
                      const TextStyle(
                    color: azul,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              // ==================================================
              // EDITAR
              // SOLO ADMINISTRADOR
              // ==================================================

              if (puedeEditar) ...[
                const SizedBox(
                  width: 5,
                ),

                IconButton(
                  tooltip:
                      'Editar categoría',

                  onPressed:
                      onEditar,

                  icon:
                      Icon(
                    categoria.activo
                        ? Icons
                            .edit_outlined
                        : Icons
                            .settings_outlined,

                    color:
                        azul,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// DIALOG NUEVA / EDITAR
// =================================================================

class _CategoriaDialog
    extends StatefulWidget {
  final Categoria? categoria;

  final bool esAdministrador;

  const _CategoriaDialog({
    this.categoria,
    required this.esAdministrador,
  });

  @override
  State<_CategoriaDialog> createState() =>
      _CategoriaDialogState();
}

class _CategoriaDialogState
    extends State<_CategoriaDialog> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      nombreController;

  bool activo = true;
  bool guardando = false;

  bool get esEdicion =>
      widget.categoria != null;

  bool get puedeEditar =>
      widget.esAdministrador;

  static const Color azul =
      Color(0xFF1565C0);

  static const Color texto =
      Color(0xFF172B4D);

  @override
  void initState() {
    super.initState();

    nombreController =
        TextEditingController(
      text:
          widget.categoria?.nombre ??
              '',
    );

    activo =
        widget.categoria?.activo ??
            true;
  }

  @override
  void dispose() {
    nombreController.dispose();

    super.dispose();
  }

  // ============================================================
  // GUARDAR
  // ============================================================

  Future<void> guardar() async {
    FocusScope.of(context)
        .unfocus();

    if (!puedeEditar) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'No tienes permisos para modificar categorías.',
          ),
        ),
      );

      return;
    }

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      // ========================================================
      // EDITAR CATEGORÍA EXISTENTE
      // ========================================================

      if (esEdicion) {
        final categoriaOriginal =
            widget.categoria!;

        final nombreNuevo =
            nombreController.text.trim();

        final nombreCambio =
            nombreNuevo !=
                categoriaOriginal.nombre;

        final estadoCambio =
            activo !=
                categoriaOriginal.activo;

        // ------------------------------------------------------
        // ACTUALIZAR NOMBRE Y/O ESTADO
        // ------------------------------------------------------

        if (nombreCambio ||
            estadoCambio) {
          final categoriaActualizada =
              Categoria(
            idCategoria:
                categoriaOriginal
                    .idCategoria,
            nombre:
                nombreNuevo,
            activo:
                activo,
          );

          await CategoriaService
              .actualizarCategoria(
            categoriaActualizada,
          );
        }
      }

      // ========================================================
      // CREAR NUEVA CATEGORÍA
      // ========================================================

      else {
        final categoria =
            Categoria(
          idCategoria: 0,
          nombre:
              nombreController
                  .text
                  .trim(),
          activo:
              activo,
        );

        await CategoriaService
            .crearCategoria(
          categoria,
        );
      }

      if (!mounted) return;

      Navigator.of(context)
          .pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              const Icon(
                Icons.error_outline,
                color:
                    Colors.white,
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Text(
                  'No se pudo guardar la categoría.\n$e',
                ),
              ),
            ],
          ),

          backgroundColor:
              Colors.red.shade700,

          behavior:
              SnackBarBehavior.floating,

          margin:
              const EdgeInsets.all(
            16,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),

          duration:
              const Duration(
            seconds: 5,
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      backgroundColor:
          Colors.white,

      surfaceTintColor:
          Colors.white,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          22,
        ),
      ),

      titlePadding:
          const EdgeInsets.fromLTRB(
        24,
        22,
        24,
        8,
      ),

      contentPadding:
          const EdgeInsets.fromLTRB(
        24,
        8,
        24,
        10,
      ),

      actionsPadding:
          const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        18,
      ),

      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,

            decoration:
                BoxDecoration(
              color:
                  azul.withValues(
                alpha: 0.10,
              ),

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(
              esEdicion
                  ? Icons.edit_rounded
                  : Icons
                      .category_rounded,

              color: azul,
              size: 23,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              esEdicion
                  ? 'Editar categoría'
                  : 'Nueva categoría',

              style:
                  const TextStyle(
                color: texto,
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      content:
          SingleChildScrollView(
        child: Form(
          key: _formKey,

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              const SizedBox(
                height: 8,
              ),

              Text(
                esEdicion
                    ? 'Puedes modificar el nombre y el estado de la categoría.'
                    : 'Ingresa el nombre de la nueva categoría.',

                style:
                    const TextStyle(
                  color:
                      Color(0xFF6B778C),
                  fontSize: 13,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // NOMBRE
              // ==================================================

              TextFormField(
                controller:
                    nombreController,

                enabled:
                    !guardando &&
                    puedeEditar,

                autofocus:
                    !esEdicion &&
                    puedeEditar,

                textCapitalization:
                    TextCapitalization
                        .words,

                maxLength: 100,

                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                    100,
                  ),
                ],

                decoration:
                    InputDecoration(
                  labelText:
                      'Nombre de categoría',

                  hintText:
                      'Ej. Electrónica',

                  prefixIcon:
                      const Icon(
                    Icons
                        .category_outlined,
                    color: azul,
                  ),

                  filled: true,

                  fillColor:
                      const Color(
                    0xFFF8FAFC,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    borderSide:
                        const BorderSide(
                      color:
                          Color(
                        0xFFD9E0E8,
                      ),
                    ),
                  ),

                  disabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    borderSide:
                        const BorderSide(
                      color:
                          Color(
                        0xFFD9E0E8,
                      ),
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    borderSide:
                        const BorderSide(
                      color: azul,
                      width: 2,
                    ),
                  ),
                ),

                validator:
                    (valor) {
                  final nombre =
                      valor?.trim() ??
                          '';

                  if (nombre.isEmpty) {
                    return 'Ingrese el nombre de la categoría';
                  }

                  if (nombre.length <
                      2) {
                    return 'El nombre es demasiado corto';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 8,
              ),

              // ==================================================
              // ESTADO
              // ==================================================

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF8FAFC,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),

                  border:
                      Border.all(
                    color:
                        const Color(
                      0xFFD9E0E8,
                    ),
                  ),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          const Text(
                            'Categoría activa',
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),

                          const SizedBox(
                            height: 3,
                          ),

                          Text(
                            activo
                                ? 'Disponible para los productos'
                                : 'No disponible para nuevos productos',

                            style:
                                const TextStyle(
                              fontSize:
                                  12,
                              color:
                                  Color(
                                0xFF6B778C,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Switch(
                      value:
                          activo,

                      activeThumbColor:
                          Colors.green,

                      onChanged:
                          guardando ||
                                  !puedeEditar
                              ? null
                              : (valor) {
                                  setState(
                                    () {
                                      activo =
                                          valor;
                                    },
                                  );
                                },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ==========================================================
      // BOTONES
      // ==========================================================

      actions: [
        OutlinedButton(
          onPressed:
              guardando
                  ? null
                  : () {
                      Navigator.of(
                        context,
                      ).pop(false);
                    },

          style:
              OutlinedButton.styleFrom(
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
          ),

          child:
              const Text(
            'Cancelar',
          ),
        ),

        ElevatedButton.icon(
          onPressed:
              guardando ||
                      !puedeEditar
                  ? null
                  : guardar,

          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                azul,

            foregroundColor:
                Colors.white,

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
          ),

          icon: guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,

                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                        Colors.white,
                  ),
                )
              : Icon(
                  esEdicion
                      ? Icons
                          .save_rounded
                      : Icons
                          .add_rounded,
                ),

          label:
              Text(
            guardando
                ? 'Guardando...'
                : esEdicion
                    ? 'Actualizar'
                    : 'Guardar',
          ),
        ),
      ],
    );
  }
}

// =================================================================
// ESTADO VACÍO
// =================================================================

class _EstadoVacio
    extends StatelessWidget {
  final bool puedeCrear;
  final VoidCallback onCrear;

  const _EstadoVacio({
    required this.puedeCrear,
    required this.onCrear,
  });

  static const Color azul =
      Color(0xFF1565C0);

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      padding:
          const EdgeInsets.all(
        20,
      ),

      children: [
        const SizedBox(
          height: 70,
        ),

        Container(
          width: 90,
          height: 90,

          decoration:
              BoxDecoration(
            color:
                azul.withValues(
              alpha: 0.08,
            ),
            shape:
                BoxShape.circle,
          ),

          child: const Icon(
            Icons.category_outlined,
            size: 48,
            color: azul,
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        const Center(
          child: Text(
            'No hay categorías',
            style:
                TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        const Center(
          child: Text(
            'Todavía no existen categorías registradas.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        if (puedeCrear)
          Center(
            child:
                ElevatedButton.icon(
              onPressed:
                  onCrear,

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    azul,
                foregroundColor:
                    Colors.white,
              ),

              icon:
                  const Icon(
                Icons.add_rounded,
              ),

              label:
                  const Text(
                'Crear categoría',
              ),
            ),
          ),
      ],
    );
  }
}

// =================================================================
// SIN RESULTADOS
// =================================================================

class _SinResultados
    extends StatelessWidget {
  const _SinResultados();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        top: 15,
      ),

      padding:
          const EdgeInsets.all(
        30,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFD9E0E8,
          ),
        ),
      ),

      child:
          const Column(
        children: [
          Icon(
            Icons
                .search_off_rounded,
            size: 48,
            color:
                Colors.grey,
          ),

          SizedBox(
            height: 12,
          ),

          Text(
            'No se encontraron categorías',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(
            height: 5,
          ),

          Text(
            'Prueba con otro nombre.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}