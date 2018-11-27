#define N_MSG 5
#define N_ESC 3

byte MSG_ENV;
byte MSG_REC;

byte colou = 0;
byte chegou = 0;
byte no_pombo = 0;
byte no_in = 0;

proctype pombo(chan in_c; chan out_c) {
    int i; 
    int j;
    byte msg;
    chan buffer = [N_MSG] of {byte};

    for(i : 1 .. N_ESC) {
        for(j : 1 .. N_MSG) {
            atomic {
                in_c?msg;
                no_in = no_in - 1;
                no_pombo = no_pombo + 1;
            }
            
            buffer!msg;        
        }

        for(j : 1 .. N_MSG) {
            buffer?msg;
            out_c!msg;
            no_pombo = 0;
        }
    }
}

proctype escritor(chan c) {
    int i;
    byte msg = 65;

    for(i : 1 .. N_MSG) {
        atomic {
            c!msg;
            MSG_ENV = msg;
            no_in = no_in + 1;
        }
        msg = msg+1;
    }
}

proctype leitor(chan c) {
    int i;
    byte msg;
    for(i : 1 .. N_MSG * N_ESC) {
        atomic {
            c?msg;
            MSG_REC = msg;
            chegou = chegou+1;
        }
    }
}

init {
    chan in_c  = [10] of {byte};
    chan out_c = [0] of {byte};
    int i;

    atomic {
        run pombo(in_c, out_c);
        run leitor(out_c);

        for(i : 1 .. N_ESC) {
            run escritor(in_c);
        }
    }

}

#define ENV_66 (MSG_ENV == 66)
#define REC_66 (MSG_REC == 66)

#define colou_todas (colou == N_MSG * N_ESC)
ltl{ <>colou_todas }

#define chegou_todas (chegou == N_MSG * N_ESC)
ltl{ <>chegou_todas }

#define cola_depois_chega (chegou <= colou)
ltl{ []cola_depois_chega }

#define limite_pombo (no_pombo <= N_MSG)
ltl{ []limite_pombo }

#define so_um_escreve (no_in <= 1)
ltl{ []so_um_escreve }
