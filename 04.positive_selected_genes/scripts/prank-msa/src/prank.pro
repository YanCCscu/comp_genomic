# -------------------------------------------------
# Project created by QtCreator 2010-06-28T10:03:12
# -------------------------------------------------
QT -= core \
    gui \
    webkit
TARGET = prank
CONFIG = debug

#CONFIG += console
#CONFIG -= app_bundle
TEMPLATE = app
SOURCES += writefile.cpp \
    treenode.cpp \
    translatesequences.cpp \
    terminalsequence.cpp \
    terminalnode.cpp \
    site.cpp \
    sequence.cpp \
    readnewick.cpp \
    readfile.cpp \
    readalignment.cpp \
    pwsite.cpp \
    pwhirschberg.cpp \
    progressivealignment.cpp \
    prank.cpp \
    postprobability.cpp \
    phylomatchscore.cpp \
    node.cpp \
    intmatrix.cpp \
    hmmodel.cpp \
    hirschberg.cpp \
    guidetree.cpp \
    fullprobability.cpp \
    flmatrix.cpp \
    eigen.cpp \
    dbmatrix.cpp \
    characterprobability.cpp \
    boolmatrix.cpp \
    ancestralsequence.cpp \
    ancestralnode.cpp \
    check_version.cpp \
    exonerate_reads.cpp \
    mafft_alignment.cpp \
    bppancestors.cpp
OTHER_FILES += \  
    ../VERSION_HISTORY \
    prank.1.pod \
    Makefile.no_Qt \
    Makefile
HEADERS += writefile.h \
    treenode.h \
    translatesequences.h \
    terminalsequence.h \
    terminalnode.h \
    site.h \
    sequence.h \
    readnewick.h \
    readfile.h \
    readalignment.h \
    pwsite.h \
    pwhirschberg.h \
    progressivealignment.h \
    prank.h \
    postprobability.h \
    phylomatchscore.h \
    node.h \
    intmatrix.h \
    hmmodel.h \
    hirschberg.h \
    guidetree.h \
    fullprobability.h \
    flmatrix.h \
    eigen.h \
    dbmatrix.h \
    config.h \
    characterprobability.h \
    boolmatrix.h \
    ancestralsequence.h \
    ancestralnode.h \
    check_version.h \
    exonerate_reads.h \
    mafft_alignment.h \
    bppancestors.h


INCLUDEPATH += /usr/include












