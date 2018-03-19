clc;
clear;
clear all;

addpath(genpath('functions'))

%Test Uni sulle Ancore
pathTest1 = '4tests_10x10_step_1_uni_18_03_14';
posizioniTest1 = [0 0; 10 0; 10 10; 0 10];
Test1 = controlloLogBlind(pathTest1, posizioniTest1);

%Test Casa Gio sulle Ancore
pathTest2 = '4tests_10x10_step_1_casa_gio_sulleancore_18_03_19';
posizioniTest2 = [0 0; 10 0; 10 10; 0 10];
Test2 = controlloLogBlind(pathTest2, posizioniTest2);

%Test Casa Gio in giro
pathTest3 = '4tests_10x10_step_1_casa_gio_ingiro_18_03_19';
posizioniTest3 = [5 0; 5 5; 5 10; 0 5];
Test3 = controlloLogBlind(pathTest3, posizioniTest3);

disp('Terminato')