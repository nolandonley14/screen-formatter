! Screen Formatter in Fortran
! Nolan Donley
! Input: any text file
! Output: text file formatter to maximum 60 chars per Line
!      and also the line with most and least words
!
! To compile:
! gfortran formatter.f95
!
! To run:
! ./a.out {absolute filepath}

program formatter
    implicit none
    character(len = 100) :: word, fileName ! string size 100 for each word, and the fileName
    character(len = 4000) :: buffer ! string size 4000 for each line of input
    character(len = 61) :: longLine, shortLine, tmp ! string size 61 for each line of output
    character(:), allocatable :: longString ! string of unknown size for total input
    integer :: filesize, i, counter, longLineNum, shortLineNum ! integers for filesize, 2 iterators, line numbers for long and short lines
    integer :: ios = 0, lineNum = 1, lineSize = 0, found = 0, numWords = 0, lLWordCount = 0, sLWordCount = 0 ! integers for iterators, number of lines, current line size, number of words in tmp, and number of words in long and short lines
    logical :: nextLine = .false. ! boolean to determine if we have past 60 chars in the output

    interface

      ! function that reads the file fileName and stores it in string
      subroutine read_file( string, filesize, fileName)
        character(:), allocatable :: string
        character(len=50) :: fileName
        integer :: counter
        integer :: filesize
        character (LEN=1) :: input
      end subroutine read_file

      ! function that tokenizes string into word by space
      subroutine getNextWord(string, word)
        character(:), allocatable :: string
        character(len = 100) :: word
      end subroutine getNextWord

      ! function that removes numbers and extra spaces from word
      subroutine cleanWord ( word )
        character(len = 100) :: word
        integer :: found
      end subroutine cleanWord

      ! function that conditionally prints word to the screen
      subroutine printWord ( word, lineSize, tmp, lineNum, nextLine, numWords )
        character(len = 100) :: word
        character(len = 61) :: tmp
        integer :: lineSize, lineNum, numWords
        logical :: nextLine
      end subroutine printWord

      ! function to update the maximum and minimum lines and their line numbers
      subroutine updateMinMax( tmp, numWords, longLine, shortLine, lineNum, sLWordCount, lLWordCount, shortLineNum, longLineNum )
        character(len = 61) :: tmp, longLine, shortLine
        integer :: lineNum, numWords, sLWordCount, lLWordCount, shortLineNum, longLineNum
      end subroutine updateMinMax

    end interface

    ! read filename in from the command line arguments
    if(COMMAND_ARGUMENT_COUNT().ne.1) then
    write(*,*)'ERROR, File Command-Line Arrgument Required, STOPPING'
      stop
    end if

    do i = 1, iargc()
      call getarg(i, fileName)
    end do

    write (*, fmt="(/,4x,i4,2x)", advance="no") lineNum
    tmp = " "

    ! read the file into longstring
    call read_file(longString, filesize, fileName)
    do while (len(longString) > 0)
      ! get next word from long string
      call getNextWord(longString, word)
      ! clean the word
      call cleanWord(word)
      ! print the word to the screen or print newline then the word
      call printWord(word, lineSize, tmp, lineNum, nextLine, numWords)
      ! if new line is printed, update the max and min lines based on the last line of output
      if (nextLine .eqv. .true.) then
        call updateMinMax(tmp, numWords, longLine, shortLine, lineNum - 1, sLWordCount, lLWordCount, shortLineNum, longLineNum)
        tmp = word // " "
        numWords = 1
        nextLine = .false.
      end if
    end do
    ! update max and min with the last line of output
    call updateMinMax(tmp, numWords, longLine, shortLine, lineNum, sLWordCount, lLWordCount, shortLineNum, longLineNum)

    ! print out the long and short lines and their line numbers
    write (*, fmt="(//,a,i4,10x,a61)") "LONG", longLineNum, longLine
    write (*, fmt="(a,i3,11x,a60,/)") "SHORT", shortLineNum, shortLine

end program formatter

subroutine updateMinMax( tmp, numWords, longLine, shortLine, lineNum, sLWordCount, lLWordCount, shortLineNum, longLineNum )
  character(len = 61) :: tmp, longLine, shortLine
  integer :: lineNum, numWords, sLWordCount, lLWordCount, shortLineNum, longLineNum

  if (numWords <= sLWordCount) then
    shortLine = tmp
    shortLineNum = lineNum
    sLWordCount = numWords
  end if
  if (numWords >= lLWordCount) then
    longLine = tmp
    longLineNum = lineNum
    lLWordCount = numWords
  end if
  if (lineNum == 1) then
    shortLine = tmp
    shortLineNum = 1
    sLWordCount = numWords
  end if

end subroutine updateMinMax

subroutine printWord ( word, lineSize, tmp, lineNum, nextLine, numWords )

  character(len = 100) :: word
  character(len = 61) :: tmp
  integer :: lineSize, lineNum, numWords
  logical :: nextLine

  if (len(trim(word)) > 0) then
    if (lineSize + len(trim(word)) <= 60) then
      tmp = trim(tmp) // " " // trim(word) // " "
      numWords = numWords + 1
      if (lineSize + len(trim(word)) < 60) then
        write(*, fmt="(a,1x)", advance="no") trim(word)
        lineSize = lineSize + 1
      else
        write(*, fmt="(a)", advance="no") trim(word)
      end if
      lineSize = lineSize + len(trim(word))
    else
      nextLine = .true.
      lineNum = lineNum + 1
      write(*, fmt="(/,4x,i4,2x,a,1x)", advance="no") lineNum, trim(word)
      lineSize = len(trim(word)) + 1
    end if
  end if

end subroutine printWord

subroutine cleanWord ( word )

  character(len = 100) :: word
  integer :: found

  do while (scan(trim(word), "0123456789") /= 0)
    found = scan(trim(word), "0123456789")
    if (found == 1) then
      word = word(2:)
    else
      word = word(1:found-1) // word(found+1:)
    end if
  end do
end subroutine cleanWord

subroutine getNextWord(string, word)

    character(:), allocatable :: string
    character(len = 100) :: word

    do i=1, len(string)
      if (string(i:i) == " ") then
          word = string(1:i)
          string = string(i+1:)
          exit
      else if (string(i:i) == new_line('A')) then
          word = string(1:i-2)
          string = string(i+1:)
          exit
      end if
    end do

end subroutine getNextWord

subroutine read_file( string, filesize, fileName )

    character(:), allocatable :: string
    character(len=50) :: fileName
    integer :: counter
    integer :: filesize
    character (LEN=1) :: input

    inquire (file=fileName, size=filesize)
    open (unit=5,status="old",access="direct",form="unformatted",recl=1,&
    file= filename)
    allocate( character(filesize+1) :: string )

    counter=1
    100 read (5,rec=counter,err=200) input
      string(counter:counter) = input
      counter=counter+1
      goto 100
    200 continue
    counter=counter-1
    close (5)
    string(filesize+1:filesize+1) = " "

end subroutine read_file
