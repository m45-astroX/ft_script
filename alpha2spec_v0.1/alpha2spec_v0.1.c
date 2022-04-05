/*
 
 alpha2spec_v0.1.c
 
 yuma aoki
 
 2022.03.12
 
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main ( int argc, char *argv[] ) {
    
    // args
    if ( argc != 3 ) {
        printf("[inputFile(alphaFormat)] [outputFile]\n");
        return -1;
    }
    
    // var
    int CCD_ID = 0;
    int SEGMENT = 0;
    int GRADE = 0;
    int RAWX = 0;
    int RAWY = 0;
    int PHA = 0;
    int EVENT = 0;
    
    char buf[256];
    int spec[4096];
    
    // reset
    for ( int i=0; i<4096; i++ ) {
        spec[i] = 0;
    }
    
    // fp
    FILE *inputFile = NULL;
    FILE *outputFile = NULL;
    
    inputFile = fopen(argv[1], "r");
    if ( inputFile == NULL ) {
        printf("Error : inputFile\n");
        return -1;
    }
    outputFile = fopen(argv[2], "w");
    if ( inputFile == NULL ) {
        printf("Error : outputFile\n");
        return -1;
    }
    
    while ( fgets( buf, sizeof(buf), inputFile ) != NULL ) {
        
        if( strncmp(buf,"//",2) == 0 || strcmp(buf,"\n") == 0 ) {
            continue;
        }
        
        if( sscanf( buf, "%d %d %d %d %d %d %d", &CCD_ID, &SEGMENT, &GRADE, &RAWX, &RAWY, &PHA, &EVENT ) != 7 ) {
            continue;
        }
        
        if ( 0 <= PHA && PHA <= 4095 ) {
            spec[PHA] ++;
        }
        
    }
    
    // output
    //fprintf(outputFile, "!PHA, Counts\n");
    //fprintf(outputFile, "SKIP SINGLE\n");
    for ( int i=0; i<4096; i++ ) {
        fprintf(outputFile,"%d %d\n", i, spec[i]);
    }
    //fprintf(outputFile, "NO\n");
    
    // close file
    fclose(inputFile);
    fclose(outputFile);
    
    return 0;
    
}

