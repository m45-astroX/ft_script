#!/bin/csh -f

# calcResidual1.csh

# calculate residual
# residual = PHA0 - model

# 2021.09.15



# set analysis mode
set outputFileType = 2      # 1 : dat, 2 : csv
set devMode = 0             # do not change

# set reference
set noise_ref = ( 0 2 3 4 6 8 )
set grade_ref = ( 0 2 3 4 6 )

# set dir name
set coedir = ./coefficient
set inputdir = ./datForGnuplot
set outputdir = ./residual
set tempdir = ./TEMP_CALCRED

# arguments
if ( $#argv == 1 ) then
    if ( $argv[1] == 1 ) then
        printf "\ndeveloper mode\n"
        set devMode = 1
    endif
endif

# dir check
if ( -e $outputdir ) then

    printf "${outputdir} exists...\n\n"
    printf "\t$ rm -rf ${outputdir}\n\n"

    if ( $devMode == 1 ) then
        echo "developer mode...(1)"
        echo "remove ${outputdir} ...done"
        rm -rf $outputdir
    else
        exit
    endif
endif
if ( -e $tempdir ) then
    echo "remove ${tempdir} ...done"
    rm -rf $tempdir
endif

# make dir
mkdir $tempdir
mkdir $outputdir



### calculate residual ###

# noise loop
@ i = 1
while ( $i <= $#noise_ref )
    
    # grade loop
    @ j = 1
    while ( $j <= $#grade_ref )
        
        # set file name
        set inputFile = ${inputdir}/goffset_noise${noise_ref[$i]}_grade${grade_ref[$j]}_ForGnuplot.dat
        set outputFile = ${tempdir}/bef_red_goffset_noise${noise_ref[$i]}_grade${grade_ref[$j]}.dat
        set inputFile_coe = ${coedir}/fitResult_noise${noise_ref[$i]}.dat     #* coefficient File
        
        # read the number of data
        set dataNumber = `wc -l ${inputFile} | awk '{print $1}'`
        
        # coefficient
        set a = `sed -n ${j}p $inputFile_coe | awk '{print $1}'`
        set b = `sed -n ${j}p $inputFile_coe | awk '{print $2}'`
        set c = `sed -n ${j}p $inputFile_coe | awk '{print $3}'`
        
        # data loop
        @ k = 1
        while ( $k <= $dataNumber )
            
            # value
            set x = `sed -n ${k}p $inputFile | awk '{print $1}'`            #* x value (PHA0)
            set PHA0 = $x                                                   #* PHA0
            set goffset = `sed -n ${k}p $inputFile | awk '{print $2}'`      #* y value (goffset)
            
            if ( `echo "0 <= ${PHA0}" | bc` == 1 && `echo "${PHA0} < 306.5" | bc` == 1 ) then
            
                ### f(x) ###
                
                # calculate model value
                set model = `echo "${a} + ${b} * ( ${x} - 306.5 ) + ${c} * ( ${x} - 306.5 )^2" | bc | awk '{printf "%.10f", $0}'`
                
                # calculate residual
                set residual = `echo "${goffset} - ${model}" | bc | awk '{printf "%.10f", $0}'`
                
            else if ( `echo "306.5 <= ${PHA0}" | bc` == 1 && `echo "${PHA0} < 2000" | bc` == 1 ) then
                
                ### g(x) ###

                # calculate model value
                set model = `echo "${a} + ${b} * ( ${x} - 306.5 )" | bc | awk '{printf "%.10f", $0}'`

                # calculate residual
                set residual = `echo "${goffset} - ${model}" | bc | awk '{printf "%.10f", $0}'`
                
            else if ( `echo "2000 <= ${PHA0}" | bc` == 1  ) then
                
                ### h(x) ###
                
                # calculate model value
                set model = `echo "${a} + ${b} * ( 2000 - 306.5 )" | bc | awk '{printf "%.10f", $0}'`
                
                # calculate residual
                set residual = `echo "${goffset} - ${model}" | bc | awk '{printf "%.10f", $0}'`
                
            else
                
                echo "error : 001"
                exit
                
            endif

            # significant digits
            if ( `echo "${residual} > 0" | bc`  == 1 ) then      ### if plus
                if ( `echo "${residual} >= 1" | bc` == 1 ) then
                    set residual = `echo "${residual}" | awk '{printf "%1.2f", $0}'`
                else if ( `echo "${residual} >= 0.1" | bc` == 1 ) then
                    set residual = `echo "${residual}" | awk '{printf "%1.3f", $0}'`
                else if ( `echo "${residual} >= 0.01" | bc` == 1 ) then
                    set residual = `echo "${residual}" | awk '{printf "%1.4f", $0}'`
                else if ( `echo "${residual} >= 0.001" | bc` == 1 ) then
                    set residual = `echo "${residual}" | awk '{printf "%1.5f", $0}'`
                else if ( `echo "${residual} >= 0.0001" | bc` == 1 ) then
                    set residual = `echo "${residual}" | awk '{printf "%1.6f", $0}'`
                else if ( `echo "${residual} >= 0.00001" | bc` == 1 ) then
                    set residual = `echo "${residual}" | awk '{printf "%1.7f", $0}'`
                else if ( `echo "${residual} >= 0.000001" | bc` == 1 ) then
                    set residual = `echo "${residual}" | awk '{printf "%1.8f", $0}'`
                else
                    echo "residual not changed"
                endif
            else                                                ### if minus
                if ( `echo "${residual} <= -1" | bc` == 1 ) then
                    set residual = `echo "${residual}" | awk '{printf "%1.2f", $0}'`
                else if ( `echo "${residual} <= -0.1" | bc` == 1 ) then
                    set residual = `echo "${residual}" | awk '{printf "%1.3f", $0}'`
                else if ( `echo "${residual} <= -0.01" | bc` == 1 ) then
                    set residual = `echo "${residual}" | awk '{printf "%1.4f", $0}'`
                else if ( `echo "${residual} <= -0.001" | bc` == 1 ) then
                    set residual = `echo "${residual}" | awk '{printf "%1.5f", $0}'`
                else if ( `echo "${residual} <= -0.0001" | bc` == 1 ) then
                    set residual = `echo "${residual}" | awk '{printf "%1.6f", $0}'`
                else if ( `echo "${residual} <= -0.00001" | bc` == 1 ) then
                    set residual = `echo "${residual}" | awk '{printf "%1.7f", $0}'`
                else if ( `echo "${residual} <= -0.000001" | bc` == 1 ) then
                    set residual = `echo "${residual}" | awk '{printf "%1.8f", $0}'`
                else
                    echo "residual not changed"
                endif
            endif

            
            # write to output file
            printf "${PHA0}\t${residual}\n" >> $outputFile
            
            @ k ++
        end
        
        @ j ++
    end
    
    @ i ++
end



### output result ###

if ( $outputFileType == 1 ) then

    ### output dat file ###

    # noise loop
    @ i = 1
    while ( $i <= $#noise_ref ) 

        # grade loop
        @ j = 1
        while ( $j <= $#grade_ref )

            # set file name
            set inputFile = ${tempdir}/bef_red_goffset_noise${noise_ref[$i]}_grade${grade_ref[$j]}.dat
            set outputFile = ${outputdir}/red_goffset_noise${noise_ref[$i]}_grade${grade_ref[$j]}.dat

            # write to outputFile
            printf "#PHA0\tResidual\n" >> $outputFile
            cat $inputFile >> $outputFile

            @ j ++
        end
    
        @ i ++
    end

else if ( $outputFileType == 2 ) then 

    ### output csv file ###
    
    # noise loop
    @ i = 1
    while ( $i <= $#noise_ref ) 

        # set fileName
        set outputFile = ${outputdir}/red_goffset_noise${noise_ref[$i]}.csv
        @ j = 1         # * want to check dataNumber *
        set inputFile = ${tempdir}/bef_red_goffset_noise${noise_ref[$i]}_grade${grade_ref[$j]}.dat

        # write to outputFile
        set dataNumber = `wc -l ${inputFile} | awk '{print $1}'`    # set dataNumber 
        printf "noise${noise_ref[$i]}" >> $outputFile
        @ n = 1
        while ( $n <= $dataNumber )
            set PHA0 = `sed -n ${n}p $inputFile | awk '{print $1}'`
            printf ", ${PHA0}" >> $outputFile
            @ n ++
        end

        printf "\n" >> $outputFile

        # grade loop
        @ j = 1
        while ( $j <= $#grade_ref ) 
            
            # set fileName
            set inputFile = ${tempdir}/bef_red_goffset_noise${noise_ref[$i]}_grade${grade_ref[$j]}.dat

            # set number of data
            set dataNumber = `wc -l ${inputFile} | awk '{print $1}'`

            # write to outputFile
            printf "Grade${grade_ref[$j]}" >> $outputFile

            # PHA0 loop (dataNumber loop) 
            @ k = 1
            while ( $k <= $dataNumber ) 

                # set residual
                set residual = `sed -n ${k}p $inputFile | awk '{print $2}'`

                # write to outputFile
                printf ",=" >> $outputFile
                doubleQ $outputFile
                echo -n $residual >> $outputFile
                doubleQ $outputFile

                @ k ++
            end

            # write to outputFile
            printf "\n" >> $outputFile

            @ j ++
        end

        @ i ++
    end

endif


### finish ###
#rm -rf $tempdir

exit

