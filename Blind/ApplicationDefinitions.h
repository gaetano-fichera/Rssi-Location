#ifndef APPLICATIONDEFINITIONS_H__
#define APPLICATIONDEFINITIONS_H__

enum {
  	MAX_ANCHOR = 4,
  	BUFFER_DEPTH = 10,
  	STEP_SIZE = 1,
  	CALC_POS_INTERVAL_MS = 2000,
  	STATE_START_ALGO = 0, //Inizio Singolo Algoritmo
  	STATE_END_ALGO = 1, //Fine Singolo Algoritmo
  	ID_ALGO_A = 0, //Identificativo Algoritmo ricerca su ogni punto della griglia
  	ID_ALGO_B = 1, //Identificativo Algoritmo ricerca lungo gli assi della griglia
  };

#endif //APPLICATIONDEFINITIONS_H__