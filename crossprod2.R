#crossprod2.R

#This function essentially does the same thing as crossprod, 
#but holds onto the dimension names when there are no rownames or colnames

#This grew out of a stack overflow answer located at
# http://stackoverflow.com/questions/32990217/in-r-carry-dimension-names-into-a-matrix-product

crossprod2 <- function(x, y){
  row <- dimnames(x)[2] #save rownames
  col <- dimnames(y)[2] #save colnames
  dn = list(row[[1]], col[[1]])  #put rownames and colnames in a list
  names(dn) = list(names(row), names(col)) #add the dimension names
  cp <- crossprod(x,y)         #run crossprod
  dimnames(cp) <- dn   #apply dimnames
  cp 
}