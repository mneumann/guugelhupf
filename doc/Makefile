# 
# $FreeBSD: doc/de_DE.ISO8859-1/books/handbook/Makefile,v 1.14 2002/03/13 00:44:20 ue Exp $
# $FreeBSDde: de-docproj/books/handbook/Makefile,v 1.16 2002/03/11 22:07:13 mheinen Exp $
#
# Build the FreeBSD Handbook in its German translation.
#

MAINTAINER=neumann@s-direktnet.de

DOC?= design_impl

FORMATS?= html-split 

HAS_INDEX= true

INSTALL_COMPRESSED?= gz
INSTALL_ONLY_COMPRESSED?=

# Images from the cross-document image library
#IMAGES_LIB=  callouts/1.png
#IMAGES_LIB+= callouts/2.png
#IMAGES_LIB+= callouts/3.png
#IMAGES_LIB+= callouts/4.png
#IMAGES_LIB+= callouts/5.png

# 
# SRCS lists the individual SGML files that make up the document. Changes
# to any of these files will force a rebuild
#

# SGML content
SRCS+= design_impl.sgml

IH=images/hashing
IMAGES=  ${IH}/Variance0.png ${IH}/Variance1.png ${IH}/Variance2.png ${IH}/Variance3.png 
IMAGES+= ${IH}/Empty0.png ${IH}/Empty1.png
IMAGES+= ${IH}/Max0.png ${IH}/Max1.png ${IH}/Max2.png
IMAGES+= ${IH}/Time0.png ${IH}/Time1.png 

# Entities
#SRCS+= chapters.ent 
#SRCS+= newsgroups.ent 

# alle Kapitel bauen
#CHAPTERS?= ${SRCS:M*chapter.sgml}

#SGMLFLAGS+= ${CHAPTERS:S/\/chapter.sgml//:S/^/-i chap./}

DOC_PREFIX?= /usr/doc
.include "${DOC_PREFIX}/share/mk/doc.project.mk"
