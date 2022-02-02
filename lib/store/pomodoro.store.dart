import 'dart:async';

import 'package:mobx/mobx.dart';

import 'package:vibration/vibration.dart';

part 'pomodoro.store.g.dart';

class PomodoroStore = _PomodoroStore with _$PomodoroStore;

enum TipoIntervalo { TRABALHO, DESCANSO }

abstract class _PomodoroStore with Store {
  @observable
  bool iniciado = false;

  @observable
  int minutos = 15;

  @observable
  int segundos = 0;

  @observable
  int tempoTrabalho = 15;

  @observable
  int tempoDescanso = 5;

  @observable
  TipoIntervalo tipoIntervalo = TipoIntervalo.TRABALHO;

  Timer? cronometro;

  @action
  void iniciar() {
    iniciado = true;
    cronometro = Timer.periodic(Duration(seconds: 1), (timer) {
      if (minutos == 0 && segundos == 0) {
        _trocarTipoIntervalo();
        Vibration.vibrate(duration: 1000);
      } else if (segundos == 0) {
        segundos = 59;
        minutos--;
      } else {
        segundos--;
      }
    });
  }

  @action
  void parar() {
    iniciado = false;
    cronometro?.cancel();
  }

  @action
  void reiniciar() {
    iniciado = false;
    parar();
    minutos = estaTrabalhando() ? tempoTrabalho : tempoDescanso;
    segundos = 0;
  }

  @action
  void incrementarTempoTrabalho() {
    if (tempoTrabalho < 999) {
      tempoTrabalho++;
      if (estaTrabalhando()) {
        reiniciar();
      }
    }
  }

  @action
  void decrementarTempoTrabalho() {
    if (tempoTrabalho > 1) {
      tempoTrabalho--;
      if (estaTrabalhando()) {
        reiniciar();
      }
    }
  }

  @action
  void incrementarTempoDescanso() {
    if (tempoDescanso < 999) {
      tempoDescanso++;
      if (estaDescansando()) {
        reiniciar();
      }
    }
  }

  @action
  void decrementarTempoDescanso() {
    if (tempoDescanso > 1) {
      tempoDescanso--;
      if (estaDescansando()) {
        reiniciar();
      }
    }
  }

  bool estaTrabalhando() {
    return tipoIntervalo == TipoIntervalo.TRABALHO;
  }

  bool estaDescansando() {
    return tipoIntervalo == TipoIntervalo.DESCANSO;
  }

  void _trocarTipoIntervalo() {
    if (estaTrabalhando()) {
      tipoIntervalo = TipoIntervalo.DESCANSO;
      minutos = tempoDescanso;
    } else {
      tipoIntervalo = TipoIntervalo.TRABALHO;
      minutos = tempoTrabalho;
    }
    segundos = 0;
  }
}
