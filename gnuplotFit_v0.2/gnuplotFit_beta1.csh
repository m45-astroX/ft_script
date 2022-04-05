#!/bin/csh -f

# gnuplotFit_beta1.csh

# 2021.09.09
# 2021.09.15


if ( $#argv != 0 ) then
    exit
endif

# set reference
set noise_ref = ( 0 2 3 4 6 8 )
set grade_ref = ( 0 2 3 4 6 )

# set name
set inputDatadir = ./datForGnuplot

# set outputFile-type (1:csv, 2:dat)
set outputFileType = 2

# set mode
set autoRemove = 1



##### make dir #####
if ( -e pdf ) then
    printf "dir pdf exists...\n"
    printf "\trm -rf pdf\n"
    if ( $autoRemove == 1 ) then
        printf "auto remove! -> rm -rf pdf\n"
        rm -rf pdf
    else
        exit
    endif
endif
if ( -e result ) then
    printf "dir result exists...\n"
    printf "\trm -rf result\n"
    if ( $autoRemove == 1 ) then
        printf "auto remove! -> rm -rf result\n"
        rm -rf result
    else
        exit
    endif
endif
if ( -e coefficient ) then
    printf "dir coefficient exists...\n"
    printf "\trm -rf coefficient\n"
    if ( $autoRemove == 1 ) then
        printf "auto remove! -> rm -rf coefficient\n"
        rm -rf coefficient
    else
        exit
    endif
endif

mkdir pdf
mkdir result
mkdir coefficient


##### gnuplot fitting #####

# noise loop
@ i = 1
while ( $i <= $#noise_ref )
    
    # grade loop
    @ j = 1
    while ( $j <= $#grade_ref )
        
        # change dir
        cd ${inputDatadir}
        
        # *** set inputFile ***
        set inputFile = goffset_noise${noise_ref[$i]}_grade${grade_ref[$j]}_ForGnuplot.dat
        
        # fitting
        csh ../gnuplotFit_beta2.csh ${inputFile}
        
        set resultFile1 = FIT_ResultAllData.dat
        set resultFile2 = FIT_Graph.pdf
        set resultFile1_after = fitGnuplotResult_noise${noise_ref[$i]}_grade${grade_ref[$j]}.dat
        set resultFile2_after = fitGraph_noise${noise_ref[$i]}_grade${grade_ref[$j]}.pdf
        
        # rename
        mv ${resultFile1} ${resultFile1_after}
        mv ${resultFile2} ${resultFile2_after}
        
        # move files to
        mv ${resultFile1_after} ../result/
        mv ${resultFile2_after} ../pdf/
        
        # remove detail file
        rm -rf fit.log
        
        # change dir
        cd ..
        
        @ j ++
    end
    
    @ i ++
end



##### output coefficient #####

set coe_ref = ( a b c )

if ( $outputFileType == 1 ) then        # type : csv

    # noise loop
    @ i = 1
    while ( $i <= $#noise_ref ) 

        # set fileName
        set outputFile = fitResult_noise${noise_ref[$i]}.csv

        # write to outputFile
        printf "noise${noise_ref[$i]}" >> $outputFile
        @ n = 1
        while ( $n <= $#coe_ref ) 
            printf ", ${coe_ref[$n]}" >> $outputFile
            @ n ++
        end

        # grade loop
        @ j = 1
        while ( $j <= $#grade_ref ) 
            
            # set file name
            set inputFiledir = ./result
            set inputFile = ${inputFiledir}/fitGnuplotResult_noise${noise_ref[$i]}_grade${grade_ref[$j]}.dat
            
            # write to outputFile
            printf "\nGrade ${grade_ref[$j]}" >> $outputFile

            # coefficient loop
            @ k = 1
            while ( $k <= $#coe_ref ) 

                # output coefficient
                grep "${coe_ref[$k]} = " $inputFile | awk '{printf ", %.20f",  $3}' >> $outputFile

                @ k ++
            end

            @ j ++
        end

        printf "\n" >> $outputFile

        @ i ++
    end


else if ( $outputFileType == 2 ) then   # type : dat

    # noise loop
    @ i = 1
    while ( $i <= $#noise_ref ) 

        # set fileName
        set outputFile = fitResult_noise${noise_ref[$i]}.dat

        # grade loop
        @ j = 1
        while ( $j <= $#grade_ref ) 
            
            # set file name
            set inputFiledir = ./result
            set inputFile = ${inputFiledir}/fitGnuplotResult_noise${noise_ref[$i]}_grade${grade_ref[$j]}.dat
            
            # coefficient loop
            @ k = 1
            while ( $k <= $#coe_ref ) 

                # output coefficient
                grep "${coe_ref[$k]} = " $inputFile | awk '{printf "%.20f ",  $3}' >> $outputFile

                @ k ++
            end
            
            # write to outputFile
            printf "\n" >> $outputFile
            
            @ j ++
        end

        @ i ++
    end

endif



##### move files #####
if ( $outputFileType == 1 ) then
    mv ./fitResult_noise*.csv ./coefficient/
else if ( $outputFileType == 2 ) then
    mv ./fitResult_noise*.dat ./coefficient/
endif



exit
