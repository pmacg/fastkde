load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "./markerSpec.ncl" ;Read in plot marker locations

begin


;*******************************************************************************
;*******************************************************************************
;********************** Read in data *******************************************
;*******************************************************************************
;*******************************************************************************

  ;Open the file that contains postprocessed information about the PDF
  infilename = "./postHocAnalysis2.nc"
  ;infilename = "/projects/regional/APE/updraftAnalysis/combinedPDFsOnSameGrid.nc"
  fin = addfile(infilename,"r")

  climfilename = "/buffalo/data/regional/APE/mpas-latlon/30km/mpas_655362.cam2.h0.0004.zonalavg.nc"
  fclim = addfile(climfilename,"r")

;  ;Reconstruct the estimated Hurst exponents (using Hdiff = Hfit - H)
;  Hfit = fin->H
;  Hdiff = fin->Hdiff
;  H = Hfit
;  H = Hfit - Hdiff

  H = fin->sfExponents(:,:,0)

  ;Set the title
  ;H@long_name = "Power law slope from 1~S~st~N~ order struct. func., H~B~1~N~"
  H@long_name = ""
  H@units = ""

  ;Read the lat/lev variables
  lat = H&lat
  lev = H&lev

  ;Read the Zonal wind variable
  U = fclim->U(0,:,:)


;*******************************************************************************
;*******************************************************************************
;********************** Set plot settings **************************************
;*******************************************************************************
;*******************************************************************************
  res = True
  
  ;Set contour drawing properties
  res@cnFillPalette = "nrl_sirkes" ;Set the color bar
  res@cnFillMode = "RasterFill" ;Don't smooth the data
  res@cnFillOn = True ;Color-fill the raster boxes
  res@cnLinesOn = False ;Don't draw contour lines
  res@cnLineLabelsOn = False ;Don't draw contour line labels

  ;Set axis properties (bounds, etc.)
  res@trXMinF = -50. ;Set the plot's left bound
  res@trXMaxF = 50. ;Set the plot's right bound
  res@trYMaxF = 1050. ;Set the plot's lower bound
  res@trYMinF = 80. ;Set the plot's upper bound
  res@trYReverse = True ;Put higher pressures at the bottom

  ;Set axis labels
  res@tiYAxisString = "Pressure (hPa)"

  ;Set attributes of the plot's geometry
  res@vpWidthF = 0.7 ;Set the (relative) physical width of the plot
  res@vpHeightF = 0.3 ;Set the (relative) physical width of the plot
;  res@gsnMaximize = True ;Tell NCL to remove as much whitespace as possible

  ;Set the countour levels
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = ispan(100,900,25)/1000.

  ;Tell NCL not to draw or advance the frame (so we can add text/annotation)
  res@gsnFrame = False
  res@gsnDraw = False


;*******************************************************************************
;*******************************************************************************
;********************** Draw the plot and annotations **************************
;*******************************************************************************
;*******************************************************************************

  ;Create the plot
  wks = gsn_open_wks("eps","pdfmapfiga") ;Open the worksheet (file)
  plot = gsn_csm_contour(wks,H,res) ;Create the plot


  ;Do an overlay of zonal wind
  resu = res
  delete(res@cnFillMode)
  delete(res@cnFillOn)
  resu@cnFillOn = False ;Color-fill the raster boxes
  resu@cnLinesOn = True ;Don't draw contour lines
  resu@cnLineLabelsOn = True ;Don't draw contour line labels
  resu@cnInfoLabelOn = False
  resu@cnLineColor = "Gray30"
  resu@cnLineLabelFontColor = "Gray30"
  resu@cnLineLabelBackgroundColor = -1.0
  delete(resu@cnLevels)
  delete(resu@cnLevelSelectionMode)
  U@long_name = ""
  U@units = ""
  plotu = gsn_csm_contour(wks,U,resu)

  overlay(plot,plotu)

  ;Draw the plot
  draw(plot)

  ;Draw the subfigure label
  resText = True
  resText@txFontHeightF = 0.025 ;Set the fontheight
  gsn_text(wks,plot,"(a)",-46.,100.,resText)

  ;Draw the location markers specified in markerSpec.ncl
  resMark = True
  resMark@txFontHeightF = 0.015 ;Set a smaller fontheight
  do n = 0,nmarkers-1
    gsn_text(wks,plot,""+(n+1),lat(iLatMarker(n)),lev(iLevMarker(n)),resMark)
  end do

  ;Write the plot to disk
  frame(wks)

end