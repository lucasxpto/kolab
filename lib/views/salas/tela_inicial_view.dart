import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sala_controller.dart';
import '../../models/usuario_model.dart';
import '../../services/auth_service.dart';

class TelaInicial extends StatelessWidget {
  TelaInicial({Key? key}) : super(key: key);

  final AuthService authService = AuthService();
  final SalaController salaController = Get.put(SalaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Salas Disponíveis"),
        actions: [
          FutureBuilder<Usuario?>(
            future: authService.getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null && snapshot.data!.isAdmin) {
                  return IconButton(
                    icon: Icon(Icons.admin_panel_settings),
                    onPressed: () => Get.toNamed("/salas"),
                    tooltip: "Gerenciar Salas",
                  );
                }
              }
              return SizedBox
                  .shrink(); // retorna um widget vazio se não for admin ou se ainda estiver carregando
            },
          ),
        ],
      ),
      body: Obx(() {
        if (salaController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.separated(
            itemCount: salaController.salas.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              var sala = salaController.salas[index];
              return ListTile(
                title: Text(sala.nome),
                subtitle: Text(
                    "Capacidade: ${sala.capacidade} - Custo por hora: ${sala.custoPorHora}"),
                trailing: sala.isOcupada
                    ? TextButton(
                        child: Text("Ocupada",
                            style: TextStyle(color: Colors.white)),
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: null, // desabilita a função de clique
                      )
                    : ElevatedButton(
                        child: Text("Reservar",
                            style: TextStyle(color: Colors.white)),
                            style: TextButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () {
                          salaController.reservarSala(sala);
                          Get.snackbar('Reserva', 'Sala Reservada com sucesso!',
                              snackPosition: SnackPosition.BOTTOM);
                        },
                      ),
                      
              );
            },
          );
        }
      }),
    );
  }
}
