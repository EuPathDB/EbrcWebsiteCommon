package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot;

use strict;
use vars qw( @ISA );

@ISA = qw( EbrcWebsiteCommon::View::GraphPackage::PlotPart );
use EbrcWebsiteCommon::View::GraphPackage::PlotPart;
use EbrcWebsiteCommon::View::GraphPackage::Util;
use EbrcWebsiteCommon::View::GraphPackage;

use LWP::UserAgent;
use Data::Dumper;
#--------------------------------------------------------------------------------

sub getIsFilled                  { $_[0]->{'_is_filled'                     }}
sub setIsFilled                  { $_[0]->{'_is_filled'                     } = $_[1]}

sub getForceNoLines              { $_[0]->{'_force_no_lines'                }}
sub setForceNoLines              { $_[0]->{'_force_no_lines'                } = $_[1]}

sub getForceNoPoints             { $_[0]->{'_force_no_points'               }}
sub setForceNoPoints             { $_[0]->{'_force_no_points'               } = $_[1]}

sub getVaryGlyphByXAxis          { $_[0]->{'_vary_glyph_by_x_axis'          }}
sub setVaryGlyphByXAxis          { $_[0]->{'_vary_glyph_by_x_axis'          } = $_[1]}

sub getPointsPch                 { $_[0]->{'_points_pch'                    }}
sub setPointsPch                 { $_[0]->{'_points_pch'                    } = $_[1]}

sub getDefaultXMax               { $_[0]->{'_default_x_max'                 }}
sub setDefaultXMax               { $_[0]->{'_default_x_max'                 } = $_[1]}

sub getDefaultXMin               { $_[0]->{'_default_x_min'                 }}
sub setDefaultXMin               { $_[0]->{'_default_x_min'                 } = $_[1]}

sub getAdjustXYScalesTogether    { $_[0]->{'_adjust_xy_scales_together'     }}
sub setAdjustXYScalesTogether    { $_[0]->{'_adjust_xy_scales_together'     } = $_[1]}

sub getAntisenseFloor            { $_[0]->{'antisense_floor'                }}
sub setAntisenseFloor            { $_[0]->{'antisense_floor'                } = $_[1]}

sub getAntisenseFoldChange       { $_[0]->{'antisense_fold_change'          }}
sub setAntisenseFoldChange       { $_[0]->{'antisense_fold_change'          } = $_[1]}

sub getSenseFoldChange           { $_[0]->{'sense_fold_change'              }}
sub setSenseFoldChange           { $_[0]->{'sense_fold_change'              } = $_[1]}

sub getArePointsLast             { $_[0]->{'_are_points_last'               }}
sub setArePointsLast             { $_[0]->{'_are_points_last'               } = $_[1]}

sub getSmoothLines               { $_[0]->{'_smooth_lines'                  }}
sub setSmoothLines               { $_[0]->{'_smooth_lines'                  } = $_[1]}

sub getSmoothWithLoess           { $_[0]->{'_smooth_with_loess'             }}
sub setSmoothWithLoess           { $_[0]->{'_smooth_with_loess'             } = $_[1]}

sub getPanOut                    { $_[0]->{'_pan_out'                       }}
sub setPanOut                    { $_[0]->{'_pan_out'                       } = $_[1]}

sub getSplineApproxN             { $_[0]->{'_spline_approx_n'               }}
sub setSplineApproxN             { $_[0]->{'_spline_approx_n'               } = $_[1]}

sub getSplineDF                  { $_[0]->{'_spline_degrees_of_freedom'     }}
sub setSplineDF                  { $_[0]->{'_spline_degrees_of_freedom'     } = $_[1]}

sub getHasMetaData               { $_[0]->{'_has_meta_data'                 }}
sub setHasMetaData               { $_[0]->{'_has_meta_data'                 } = $_[1]}

sub getForceConnectPoints        { $_[0]->{'_force_connect_points'          }}
sub setForceConnectPoints        { $_[0]->{'_force_connect_points'          } = $_[1]}

sub getTimeline                  { $_[0]->{'_time_line'                     }}
sub setTimeline                  { $_[0]->{'_time_line'                     } = $_[1]}

sub getColorVals                 { $_[0]->{'_color_vals'                    }}
sub setColorVals                 { $_[0]->{'_color_vals'                    } = $_[1]}

sub getColorLabels               { $_[0]->{'_color_labs'                    }}
sub setColorLabels               { $_[0]->{'_color_labs'                    } = $_[1]}

sub getFillVals                  { $_[0]->{'_fill_vals'                     }}
sub setFillVals                  { $_[0]->{'_fill_vals'                     } = $_[1]}

sub getFillLabels                { $_[0]->{'_fill_labs'                     }}
sub setFillLabels                { $_[0]->{'_fill_labs'                     } = $_[1]}

sub getCustomBreaks              { $_[0]->{'_custom_breaks'                 }}
sub setCustomBreaks              { $_[0]->{'_custom_breaks'                 } = $_[1]}

sub getFacetNumCols              { $_[0]->{'_facet_num_cols'                }}
sub setFacetNumCols              { $_[0]->{'_facet_num_cols'                } = $_[1]}

sub getColorPointsOnly           { $_[0]->{'_color_points_only'             }}
sub setColorPointsOnly           { $_[0]->{'_color_points_only'             } = $_[1]}

sub blankPlotPart {
  my ($self) = @_;
  $self->blankGGPlotPart(@_);
}

sub getStrandDictionaryHash      { $_[0]->{'_strand_dictionary_hash'        }}


#--------------------------------------------------------------------------------

sub new {
  my $class = shift;
    
  my $self = $class->SUPER::new(@_);
    
  $self->setXaxisLabel("Whoops! Object forgot to call setXaxisLabel");
  $self->setDefaultYMax(1);
  $self->setDefaultYMin(-1);
  return $self;
}

#--------------------------------------------------------------------------------

sub makeRPlotString {
  my ($self, $idType) = @_;

  my $sampleLabels = $self->getSampleLabels();
    
  my $sampleLabelsString = EbrcWebsiteCommon::View::GraphPackage::Util::rStringVectorFromArray($sampleLabels, 'x.axis.label');
    
  my $overrideXAxisLabels = scalar @$sampleLabels > 0 ? "TRUE" : "FALSE";
    
  my $isSVG = lc($self->getFormat()) eq 'svg' ? 'TRUE' : 'FALSE';
  my $isWidget = lc($self->getFormat()) eq 'html' ? 'TRUE' : 'FALSE';   
  my $colors = $self->getColors();
        
  my $blankGraph = $self->blankGGPlotPart();
    
  my $profileSetsRequest = $self->makePlotDataRequestForR($idType);
  my $plotDataJson;
  my $ua = LWP::UserAgent->new;
  push @{ $ua->requests_redirectable }, 'POST';
  my $resp = $ua->request($profileSetsRequest);
  if ($resp->is_success) {
    $plotDataJson = $resp->decoded_content;
    $plotDataJson =~ s/\'/\\\'/g;
  } else {
    print "HTTP POST error code: ", $resp->code, "\n";
    print "HTTP POST error message: ", $resp->message, "\n";
    return $blankGraph
  }
    
  my $colorsString = EbrcWebsiteCommon::View::GraphPackage::Util::rStringVectorFromArray($colors, 'the.colors');
    
  my $rAdjustProfile = $self->getAdjustProfile();
  my $yAxisLabel = $self->getYaxisLabel();
  my $xAxisLabel = $self->getXaxisLabel();
  my $plotTitle = $self->getPlotTitle();
  my $subtitle = $self->getSubtitle();
  my $statusLegend = $self->getStatusLegend();
  $statusLegend = $statusLegend ? $statusLegend : '';
  my $eventDurLegend = $self->getEventDurLegend();
  $eventDurLegend = $eventDurLegend ? $eventDurLegend : '';
    
  my $yMax = $self->getDefaultYMax();
  my $yMin = $self->getDefaultYMin();
  my $hideXAxisLabels = $self->getHideXAxisLabels() ? 'TRUE' : 'FALSE';
    
  my $xMax = $self->getDefaultXMax();
  my $xMin = $self->getDefaultXMin();

  my $adjustXYScalesTogether = $self->getAdjustXYScalesTogether();
  $adjustXYScalesTogether = defined($adjustXYScalesTogether) ? $adjustXYScalesTogether : 'FALSE';

  my $antisenseFoldChange = $self->getAntisenseFoldChange();
  $antisenseFoldChange = defined($antisenseFoldChange) ? $antisenseFoldChange : 1;

  my $senseFoldChange = $self->getSenseFoldChange();
  $senseFoldChange = defined($senseFoldChange) ? $senseFoldChange : -1;

  my $yAxisFoldInductionFromM = $self->getMakeYAxisFoldInduction();
    
  my $df = $self->getSplineDF;
  my $pointsLast = $self->getArePointsLast();
  my $rPostscript = $self->getRPostscript();
   
  my $plotlyCustomConfig = $self->getPlotlyCustomConfig();
 
  my $smoothLines = $self->getSmoothLines();
  my $smoothWithLoess = $self->getSmoothWithLoess();
    
  my $splineApproxN = $self->getSplineApproxN();
    
  my $prtcpnt_sum = $self->getPartName() eq 'prtcpnt_sum' ? 'TRUE' : 'FALSE';
  my $prtcpnt_timeline = $self->getTimeline() ? 'TRUE' : 'FALSE';
    
  my $colorVals = $self->getColorVals();
  $colorVals = $colorVals ? $colorVals : '';
  my $hasColorVals = $colorVals ? 'TRUE' : 'FALSE';


  my $colorLabels = $self->getColorLabels();
  $colorLabels = $colorLabels ? $colorLabels : '';
  my $hasColorLabels = $colorLabels ? 'TRUE' : 'FALSE';

  my $customBreaks = $self->getCustomBreaks();
  $customBreaks = $customBreaks ? $customBreaks : '';
  my $colorPointsOnly = $self->getColorPointsOnly() ? 'TRUE' : 'FALSE';

  my $fillVals = $self->getFillVals();
  $fillVals = $fillVals ? $fillVals : '';
  my $hasFillVals = $fillVals ? 'TRUE' : 'FALSE';

  my $fillLabels = $self->getFillLabels();
  $fillLabels = $fillLabels ? $fillLabels : '';
  my $hasFillLabels = $fillLabels ? 'TRUE' : 'FALSE';

  $yMax = $yMax ? $yMax : "-Inf";
  $yMin = defined($yMin) ? $yMin : "Inf";

  my $isThumbnail = "FALSE";

  if($self->getThumbnail()) {
    $isThumbnail = "TRUE";
  }

  my $isCompactString = "FALSE";

  if($self->isCompact()) {
    $yMax= "-Inf";
    $yMin = "Inf";

    $isCompactString = "TRUE";
  }

  my $coordCartesian = 'FALSE';
  if(defined($xMax) || defined($xMin)) {
    $coordCartesian = 'TRUE';
    if(!defined($xMax)) {
      $xMax = "-Inf";
    }
    if(!defined($xMin)){
      $xMin = "Inf";
    }
  } else {
    $xMax = "-Inf";
    $xMin = "Inf";
  }

  $pointsLast = $pointsLast ? 'TRUE' : 'FALSE';

  $smoothLines = $smoothLines ? 'TRUE' : 'FALSE'; 
  $smoothWithLoess = $smoothWithLoess ? 'TRUE' : 'FALSE'; 

  my $dfString;
  if($df) {
    $dfString = ", df=$df";
  }
  $df = defined($df) ? $dfString : "";

  $yAxisFoldInductionFromM = $yAxisFoldInductionFromM ? 'TRUE' : 'FALSE';

  my $forceNoPoints = $self->getForceNoPoints() ? 'TRUE' : 'FALSE';
  my $forceNoLines = $self->getForceNoLines() ? 'TRUE' : 'FALSE';
  my $forceConnectPoints = $self->getForceConnectPoints() ? 'TRUE' : 'FALSE';
  my $varyGlyphByXAxis = $self->getVaryGlyphByXAxis() ? 'TRUE' : 'FALSE';
  my $isFilled = $self->getIsFilled() ? 'TRUE' : 'FALSE';

  $rAdjustProfile = $rAdjustProfile ? $rAdjustProfile : "";

  $rPostscript = $rPostscript ? $rPostscript : "";
  $plotlyCustomConfig = $plotlyCustomConfig ? $plotlyCustomConfig : "";

  $splineApproxN = defined($splineApproxN) ? $splineApproxN : 60;

  my $bottomMargin = $self->getElementNameMarginSize();

  my $facets = $self->getFacets();
  my $facetString = "DUMMY";
  my $hasFacets = "FALSE";

  if ($facets && scalar @$facets != 0) {
    if(scalar @$facets == 1 && $facets->[0] ne 'none' && $facets->[0] ne 'na') {
      $facetString = ". ~ " . $facets->[0];
      $hasFacets = "TRUE";
    }elsif(scalar @$facets == 2) {
      if($facets->[1] ne 'none' && $facets->[0] ne 'none') {
        $facetString = $facets->[0] . " ~  " . $facets->[1];
	$hasFacets = "TRUE";
      }elsif($facets->[0] eq 'none' && $facets->[1] ne 'none') {
        $facetString = ". ~ " . $facets->[1];
	$hasFacets = "TRUE";
      }elsif($facets->[0] ne 'none' && $facets->[1] eq 'none') {
	$facetString = ". ~ " . $facets->[0];
        $hasFacets = "TRUE";
      }
    }
  }

  my $facetNumCols = $self->getFacetNumCols();
  $facetNumCols = $facetNumCols ? $facetNumCols : 0;

  my $fillBelowLine = $self->getFillBelowLine() ? 'TRUE' : 'FALSE';
  my $removeNaN = $self->getRemoveNaN() ? 'TRUE' : 'FALSE';

  my $hasExtraLegend = $self->getHasExtraLegend() ? 'TRUE' : 'FALSE';
  my $extraLegendSize = $self->getExtraLegendSize();

  #my $horizontalLegend = $self->getHorizontalLegend() ? 'TRUE' : 'FALSE';

  my $hasMetaData = $self->getHasMetaData() ? 'TRUE' : 'FALSE';

  my $titleLine = $self->getTitleLine();

  my $scale = $self->getScalingFactor;

  my $legendLabels = $self->getLegendLabels;

  my $legendLabelsString = EbrcWebsiteCommon::View::GraphPackage::Util::rStringVectorFromArray($legendLabels, 'legend.label');


  my $hasLegendLabels = $legendLabelsString ? 'TRUE' : 'FALSE';
  my $rcode = "
# ---------------------------- LINE PLOT ----------------------------


$colorsString
$sampleLabelsString
$legendLabelsString


is.compact=$isCompactString;
is.thumbnail=$isThumbnail;

#-------------------------------------------------

x.min = \"$xMin\";
x.max = \"$xMax\";

y.min = $yMin;
y.max = $yMax;  


profile.df.full = fromJSON('$plotDataJson')

if(class(profile.df.full) == 'list'){

  d = data.frame(VALUE=0.5, LABEL=\"None\");
  gp = ggplot() + geom_blank() + geom_text(data=d, mapping=aes(x=VALUE, y=VALUE, label=LABEL), size=10) + theme_void() + theme(legend.position=\"none\");

} else {

  if (\"standard_error\" %in% profile.df.full\$PROFILE_TYPE) {
  #  if (skip.stderr) {
  #    profile.df.full <- profile.df.full[profile.df.full\$PROFILE_TYPE != 'standard_error',]
  #     profile.df.full\$STDERR <- NA
  #  } else {
      profile.values <- profile.df.full[profile.df.full\$PROFILE_TYPE != 'standard_error',]
      profile.stderr <- profile.df.full[profile.df.full\$PROFILE_TYPE == 'standard_error',]
      profile.stderr\$PROFILE_TYPE <- NULL
      profile.stderr\$PROFILE_ORDER <- NULL
      names(profile.stderr)[names(profile.stderr) == 'VALUE'] <- 'STDERR'
      profile.df.full <- merge(profile.values, profile.stderr, by = c('PROFILE_SET_NAME', 'NAME', 'ELEMENT_ORDER'), all.x=TRUE)
      profile.df.full <- profile.df.full[order(profile.df.full\$PROFILE_ORDER, profile.df.full\$ELEMENT_ORDER),]
      profile.df.full\$STDERR <- as.numeric(profile.df.full\$STDERR)
  #  }
  } else {
    profile.df.full\$STDERR <- NA
  }
  
  profile.df.full\$NAME <- factor(profile.df.full\$NAME, levels=unique(profile.df.full\$NAME))
  profile.df.full\$VALUE <- as.numeric(profile.df.full\$VALUE)
  if (!\"PROFILE_SET\" %in% names(profile.df.full)) {
    profile.df.full\$PROFILE_SET <- paste(profile.df.full\$PROFILE_SET_NAME, '-', profile.df.full\$PROFILE_TYPE)
  }

  if (all(is.na(profile.df.full\$FACET))) {
    profile.df.full\$FACET <- \"Unknown\"
  }
  
  if (!is.null(legend.label)) {
    if (uniqueN(profile.df.full\$PROFILE_SET) > 1) {
      if (uniqueN(profile.df.full\$PROFILE_SET) != length(legend.label)) {
        profile.df.full\$LEGEND <- factor(profile.df.full\$PROFILE_SET, levels=unique(profile.df.full\$PROFILE_SET), labels=legend.label[legend.label %in% profile.df.full\$PROFILE_SET_NAME])
        the.colors <- the.colors[legend.label %in% profile.df.full\$PROFILE_SET_NAME]
      } else {  
        profile.df.full\$LEGEND <- factor(profile.df.full\$PROFILE_SET, levels=unique(profile.df.full\$PROFILE_SET), labels=legend.label)
      }
    } else if (nrow(profile.df.full) == length(legend.label)) {
      profile.df.full\$LEGEND <- factor(legend.label)
    } else if (uniqueN(profile.df.full\$PROFILE_ORDER) > 1) {
      profile.df.full\$LEGEND <- factor(profile.df.full\$PROFILE_ORDER, levels=unique(profile.df.full\$PROFILE_ORDER), labels=legend.label)
    } else {
      warning(\"legend.label provided, but unused.\")
    }
  }
  profile.df.full\$PROFILE_SET_NAME <- NULL
  
  if($overrideXAxisLabels && !is.null(x.axis.label)) {
    profile.df.full\$NAME <- factor(profile.df.full\$NAME, levels=unique(profile.df.full\$NAME), labels=x.axis.label)
  }
  
  names(profile.df.full)[names(profile.df.full) == \"NAME\"] <- \"ELEMENT_NAMES\"
  
  profile.df.full\$ELEMENT_NAMES_NUMERIC = as.numeric(gsub(\" *[a-z-A-Z()+-]+ *\", \"\", profile.df.full\$ELEMENT_NAMES, perl=T))
  
  #if no y values, make a placeholder (ex: timelines)
  if (!\"VALUE\" %in% colnames(profile.df.full)) {
    profile.df.full\$VALUE = NA
  }
  
  #allow adjustments
  $rAdjustProfile
  
  if ($prtcpnt_sum) {
    if (\"STATUS\" %in% colnames(profile.df.full)) {
      status.df = completeDF(profile.df.full, \"STATUS\");
    }
    if (\"DURATION\" %in% colnames(profile.df.full)) {
      annotate.df = completeDF(profile.df.full, \"DURATION\");
    }
    if (\"EVENT\" %in% colnames(profile.df.full)) {
      event.df = completeDF(profile.df.full, \"EVENT\")
    }
    if (any(grepl(\"WHO Standards\", unique(profile.df.full\$LEGEND)))){
       generic.df = completeDF(profile.df.full, \"VALUE\")
  
       who.df = generic.df[grepl(\"WHO Standards\", generic.df\$LEGEND),]
  
       profile.df.clean = generic.df[!(grepl(\"WHO Standards\", generic.df\$LEGEND)),]
       
    }else{
  
       profile.df.clean = completeDF(profile.df.full, \"VALUE\");
    }
  
  }
  
  if(\"FACET\" %in% colnames(profile.df.full)) {
    profile.df.full\$FACET <- as.factor(profile.df.full\$FACET)
    profile.df.full\$FACET_ns=factor(profile.df.full\$FACET,levels=mixedsort(levels(profile.df.full\$FACET)));
  }
  if (!exists(\"profile.is.numeric\")) {
    profile.is.numeric = sum(!is.na(profile.df.full\$ELEMENT_NAMES_NUMERIC)) == nrow(profile.df.full);
  }
  
  #will need to look again at this if ever dates come in with a different format than R's default.
  profile.is.date = all(!is.na(as.Date(as.character(profile.df.full\$ELEMENT_NAMES), format='%Y-%m-%d')));
  
  coord.cartesian = $coordCartesian
  if($removeNaN){
    if(profile.is.numeric) {
      x.max = max(profile.df.full\$ELEMENT_NAMES_NUMERIC);
      x.min = min(profile.df.full\$ELEMENT_NAMES_NUMERIC);
      profile.df.full = completeDF(profile.df.full, \"VALUE\");
      coord.cartesian = TRUE;
    } else {
      profile.df.full = completeDF(profile.df.full, \"VALUE\");
    }
  }
  
  if (!all(is.na(profile.df.full\$VALUE))) {
    if ($prtcpnt_sum) {
      profile.df.full = profile.df.clean;
    }
  }
  
  if(\"CONTXAXIS\" %in% colnames(profile.df.full) && !all(is.na(profile.df.full\$CONTXAXIS))){
    myX <- \"CONTXAXIS\"
    profile.df.full\$CONTXAXIS <- as.numeric(profile.df.full\$CONTXAXIS)
  } else if (profile.is.numeric) {
    myX <- \"ELEMENT_NAMES_NUMERIC\"
  } else {
    myX <- \"ELEMENT_NAMES\"
  }
  
  hideLegend = FALSE
  if (is.null(profile.df.full\$LEGEND)) {
    profile.df.full\$LEGEND <- profile.df.full\$PROFILE_SET
    hideLegend = TRUE
  }
  
  #if ($isWidget) {
  #  profile.df.full <- highlight_key(profile.df.full, ~LEGEND, \"Select Legend entry\")
  #  profile.df.full <- SharedData\$new(profile.df.full)
  #}
  
  gp = ggplot(profile.df.full, aes(x=get(myX), y=VALUE, group=PROFILE_SET, color=LEGEND))
  
  if ($prtcpnt_sum) {
    if (all(is.na(profile.df.full\$VALUE))) {
      #this for the case where no real y values are to be plotted (ex: timelines)
      y.max = 2;
      y.min = 0;
      y.scale = 1;
    } else {
       #may have to change this from determining scale, to determine the order of magnitude of the scale
       #ex. instead of finding diff between max and min, find number of places (10s, 100s etc)
       y.max = max(y.max, max(profile.df.full\$VALUE, na.rm=T), na.rm=TRUE) + 1;
       y.temp = min(y.min, min(profile.df.full\$VALUE, na.rm=T), na.rm=TRUE);
       y.scale = abs(round((y.max - y.temp) / 3));
       if (y.scale < 1) {
         y.scale = 1;
       }
     y.min = y.temp - (2.25 * y.scale);
   }
  } else {
    y.max = max(y.max, max(profile.df.full\$VALUE, na.rm=TRUE), na.rm=TRUE);
    y.min = min(y.min, min(profile.df.full\$VALUE, na.rm=TRUE), na.rm=TRUE);
  }
  
  if ($adjustXYScalesTogether) {
     x.max = max(as.numeric(x.max), max(profile.df.full\$CONTXAXIS, na.rm=TRUE), na.rm=TRUE);
     x.min = min(as.numeric(x.min), min(profile.df.full\$CONTXAXIS, na.rm=TRUE), na.rm=TRUE);
     maxValue <- max(c(abs(y.max),abs(y.min),abs(x.max),abs(x.min)));
     y.max=x.max=maxValue;
     y.min=x.min=-1*maxValue;
     if ($antisenseFoldChange>0) {y.end=y.max}
     else {y.end=y.min}
     if ($senseFoldChange>0) {x.end=x.max}
     else {x.end=x.min}
     gp = gp + geom_segment(aes(x=$senseFoldChange,y=$antisenseFoldChange,xend=$senseFoldChange,yend=y.end),linetype=\"dashed\",color=\"red\");
     gp = gp + geom_segment(aes(x=$senseFoldChange,y=$antisenseFoldChange,xend=x.end,yend=$antisenseFoldChange),linetype=\"dashed\",color=\"red\");
     gp = gp + geom_abline(intercept=0,slope=1,linetype=\"dashed\",color=\"red\");
  }
  
  
  if($isSVG | $isWidget) {
    useTooltips=TRUE;
  }else{
    useTooltips=FALSE;
  }
  
  if (!$prtcpnt_timeline) {
    if (!$forceNoPoints) {
      if(useTooltips){
        if (\"TOOLTIP\" %in% colnames(profile.df.full)) {
  	if ($isWidget) {
            gp = gp + geom_point(aes(text=TOOLTIP))
          } else {
            gp = gp + geom_tooltip(aes(tooltip=TOOLTIP), real.geom=geom_point);
          }
        } else {
          if (myX == \"CONTXAXIS\") {
            gp = gp + geom_tooltip(aes(tooltip=paste0(\"x: \",get(myX), \", y: \", VALUE, \"|Sample: \", ELEMENT_NAMES)), real.geom=geom_point);
          } else {
            if (\"SIZE\" %in% colnames(profile.df.full)) {
              gp = gp + geom_tooltip(aes(tooltip=paste0(\"x: \", get(myX), \", y: \", VALUE), size=SIZE), real.geom=geom_point);
              gp = gp + scale_size_manual(values=seq(length(unique(profile.df.full\$SIZE))), breaks=unique(profile.df.full\$SIZE), labels=unique(profile.df.full\$SIZE))
            } else {
              gp = gp + geom_tooltip(aes(tooltip=paste0(\"x: \",get(myX), \", y: \", VALUE)), real.geom=geom_point);  
            }
          }
        }
      }else{
        gp = gp + geom_point();
      }
    }
    
    if (!$hasColorVals) {
      if (\"GROUP\" %in% colnames(profile.df.full)) {
        count = length(unique(profile.df.full\$GROUP));
        if (count < length(force(the.colors))) {
          stop(\"Too many colors provided. Please only provide the same number of colors as groups.\");
        }
      } else {
       if (!is.null(profile.df.full\$LEGEND) && !$prtcpnt_sum) {
        count = length(unique(profile.df.full\$LEGEND));
       } else {
        count = uniqueN(profile.df.full\$PROFILE_ORDER)
       }
        if (count < length(force(the.colors))) {
          stop(\"Too many colors provided. Please only provide the same number of colors as profiles.\");
        }
      }
    }
    
    if(!$forceNoLines) {
      #override earlier group setting if group column exists
      if (\"GROUP\" %in% colnames(profile.df.full)) {
        if (!hideLegend && useTooltips && !any(grepl(\"service\", profile.df.full\$LEGEND, fixed=TRUE))) {
          if ($colorPointsOnly) {
            gp = gp + aes(group=GROUP)
            gp = gp + geom_tooltip(aes(tooltip=LEGEND), real.geom=geom_line, color=\"black\")
          } else {
            gp = gp + aes(group=GROUP)
            gp = gp + geom_tooltip(aes(tooltip=LEGEND), real.geom=geom_line);
          }
        } else {
          if ($colorPointsOnly) {
            gp = gp + aes(group=GROUP)
            gp = gp + geom_line(color=\"black\")
          } else {
            gp = gp + aes(group=GROUP)
            gp = gp + geom_line();
          }
        }
      } else {
        if (!hideLegend && useTooltips && !any(grepl(\"service\", profile.df.full\$LEGEND, fixed=TRUE))) {
          if ($colorPointsOnly) {
            gp = gp + geom_tooltip(aes(tooltip=LEGEND), real.geom=geom_line, color=\"black\")
          } else {
             
            gp = gp + geom_tooltip(aes(tooltip=LEGEND),real.geom=geom_line)     
    
          }
        } else {
          if ($colorPointsOnly) {
            gp = gp + geom_line(color=\"black\")
          } else {
            gp = gp + geom_line();
          }
        }
      }
      if($fillBelowLine) {
        if(length(unique(profile.df.full\$LEGEND)) > 1 & useTooltips) {
          gp = gp + geom_tooltip(aes(fill=LEGEND, tooltip=LEGEND, group=LEGEND), position=\"identity\", real.geom=geom_area) + scale_fill_manual(values=rep(force(the.colors), count/length(force(the.colors))));
        } else {
          gp = gp + geom_area(aes(fill=LEGEND, group=LEGEND), position=\"identity\") + scale_fill_manual(values=rep(force(the.colors), count/length(force(the.colors))));
        }
      }
    
    }
  
    if($smoothLines) {
      if(profile.is.numeric && nrow(profile.df.full) > 10) {
        if(length(levels(factor(profile.df.full\$PROFILE_SET))) == 1) {
          gp = gp + geom_smooth(method=\"loess\");
        }
        if(length(levels(factor(profile.df.full\$PROFILE_SET))) > 1) {
           gp = gp + geom_smooth(method=\"loess\", se=FALSE);
        }
      } else {
        df2smooth = completeDF(profile.df.full, \"ELEMENT_NAMES_NUMERIC\");
        gp = gp + geom_smooth(data = df2smooth, method=\"loess\", se=FALSE, colour = \"black\", size = .5);
      }
    }
    
    if (coord.cartesian) {
      if (!is.na(as.Date(as.character(x.max), format='%Y-%m-%d'))) {
        gp = gp + scale_x_date(limits=c(as.Date(x.min),as.Date(x.max)));
      } else {
        gp = gp + coord_cartesian(xlim=c(as.numeric(x.min),as.numeric(x.max)));
      }
    }
    
    if ($hasColorVals) {
      gp = gp + scale_color_manual(values = $colorVals)
    } else {
      gp = gp + scale_colour_manual(values=rep(force(the.colors), count/length(force(the.colors))), breaks=profile.df.full\$LEGEND, labels=profile.df.full\$LEGEND, name=\"Legend\");
    }
    
    if( $fillBelowLine) {
      hideLegend=TRUE;
    }
    
    xAxisCount = length(profile.df.full\$ELEMENT_NAMES);
    
    if(is.compact) {
      gp = gp + theme_void() + theme(legend.position=\"none\");
    } else if(is.thumbnail) {
      gp = gp + theme_bw();
      
      if ($adjustXYScalesTogether) {
         gp = gp + labs(title=\"$plotTitle\", y=\"$yAxisLabel\", x=\"$xAxisLabel\");
      } else {
         gp = gp + labs(title=\"$plotTitle\", y=\"$yAxisLabel\", x=NULL);
      }
    
      gp = gp + ylim(y.min, y.max);
    
      if(!profile.is.numeric) {
        gp = gp + scale_x_discrete(label=function(x) customAbbreviate(x));
        if(xAxisCount > 3) {
          gp = gp + theme(axis.text.x  = element_text(angle=45, vjust=1, hjust=1, size=12), plot.title = element_text(colour=\"#b30000\"));
        } else {
          gp = gp + theme(axis.text.x  = element_text(angle=90,vjust=0.5, size=12), plot.title = element_text(colour=\"#b30000\"));
        }
      } else {
        gp = gp + theme(axis.text.x  = element_text(angle=90,vjust=0.5, size=12), plot.title = element_text(colour=\"#b30000\"));
      }
      gp = gp + theme(legend.position=\"none\");
    } else {
      gp = gp + theme_bw();
      gp = gp + labs(title=\"$plotTitle\", y=\"$yAxisLabel\", x=\"$xAxisLabel\");
      gp = gp + ylim(y.min, y.max);
      gp = gp + theme(plot.title = element_text(colour=\"#b30000\"));
    
      if (myX == \"CONTXAXIS\") {
        if (all(is.na(as.numeric(gsub(\" *[a-z-A-Z()+-]+ *\", \"\", profile.df.full[[myX]], perl=T))))) {
          gp = gp + theme(axis.text.x = element_blank());    
        }
      } else {
        if(!profile.is.numeric) {
          gp = gp + scale_x_discrete(label=function(x) customAbbreviate(x));
          if (xAxisCount > 50) {
            gp = gp + theme(axis.text.x = element_blank())
          } else if(xAxisCount > 3) {
            gp = gp + theme(axis.text.x  = element_text(angle=45, vjust=1, hjust=1, size=12), plot.title = element_text(colour=\"#b30000\"));
          } else {
            gp = gp + theme(axis.text.x  = element_text(angle=90,vjust=0.5, size=12), plot.title = element_text(colour=\"#b30000\"));
          }
        }
      }
    
      if(hideLegend) {
        gp = gp + theme(legend.position=\"none\");
      #} else if(\$horizontalLegend) {
      #  gp = gp + theme(legend.position=\"bottom\");
      } 
    
      maxNumChar = max(nchar(as.character(profile.df.full[[myX]])),na.rm=T);
      if (!is.na(maxNumChar)) {
        if (maxNumChar >= 18) {
          gp = gp + theme(plot.margin = margin(l=40));
        }
      }
  
    }
    
    if(\"FACET\" %in% colnames(profile.df.full)) {
      if(!all(profile.df.full\$FACET_ns == \"Unknown\")){
        numLevels=nlevels(profile.df.full\$FACET_ns);
        if ($facetNumCols != 0) {
          numCols = $facetNumCols
        } else {
          numCols=ceiling(numLevels / 2);
        }
        if (numLevels > 3) {
          gp = gp + facet_wrap( ~ FACET_ns, ncol=numCols);
        } else {
          gp = gp + facet_grid(. ~ FACET_ns);
        }
      }
    }else if($hasFacets) {
      gp = gp + facet_grid($facetString);
    }
    
    if($hideXAxisLabels) {                                                                                                                                                                                      
        gp = gp + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank());
    }
  
  }
  
  if ($prtcpnt_sum) {
  
    if (\"YLABEL\" %in% colnames(profile.df.full)) {
      if (length(unique(profile.df.full\$YLABEL)) > 1 & all(grepl(\"z-score\", unique(profile.df.full\$YLABEL)))) {
        myYLab <- \"Z-score\" 
      } else {
        myYLab <- unique(profile.df.full\$YLABEL)[1]
      }
    } else {
      myYLab <- \"$yAxisLabel\"
    }
  
    if (\"XLABEL\" %in% colnames(profile.df.full)) {
      if (length(unique(profile.df.full\$XLABEL)) > 1) {
        myXLab <- \"$xAxisLabel\"
      } else {
        myXLab <- unique(profile.df.full\$XLABEL)[1]
      }
    } else {
      myXLab <- \"$xAxisLabel\"
    }
  
  
    if (grepl(\"z-score\", myYLab) | grepl(\"Z-score\", myYLab)) {
      gp = gp + geom_hline(aes(yintercept=2, linetype = as.factor(1)), colour = \"red\");
      gp = gp + geom_hline(aes(yintercept=-2, linetype = as.factor(1)), colour = \"red\");  
   
      gp = gp + scale_linetype_manual(name=\"Red Lines\", values = c(1), labels = c(\"+/- 2 SD\"))
    }
  
    #should only ever have either event.dur OR event.start. otherwise fix legend
    event.dur = exists(\"annotate.df\") && nrow(annotate.df) > 0;
    if (event.dur) {
  
      #this to appease ggplot. otherwise wont plot a single point
      if (annotate.df\$START_DATE == annotate.df\$END_DATE) {
        annotate.df\$END_DATE = annotate.df\$END_DATE + 1;
      }
   
      #this to remove consecutive rows, only need start date and duration
      annotate.df\$DIFF <- c(0, abs(diff(annotate.df\$START_DATE)) == 1)
      annotate.df <- annotate.df[annotate.df\$DIFF == 0,]
  
      annotate.df\$TOOLTIP <- paste0(\"Start: \", annotate.df\$START_DATE, \"|Duration: \", annotate.df\$DURATION)
      annotate.df\$TOOLTIP[is.na(annotate.df\$DURATION)] <- NA
      gp = gp + geom_tooltip(data = annotate.df, aes(x = START_DATE, y = min(profile.df.clean\$VALUE) - y.scale, xend = END_DATE, yend = min(profile.df.clean\$VALUE) - y.scale, tooltip = TOOLTIP, size = as.factor(7)), real.geom = geom_segment)
  
      #custom legend
      gp = gp + scale_size_manual(name = \"Bars\", values = c(7), labels = c(\"$eventDurLegend\"))
      if ($hasColorVals) {
        colorVector <- $colorVals
        gp = gp + guides(size = guide_legend(override.aes = list(color = c(unname(colorVector[names(colorVector) == unique(annotate.df\$LEGEND)[1]])))))
      } else {
        gp = gp + guides(size = guide_legend(override.aes = list(color = c(the.colors[length(the.colors)]))))
      }
    }
  
    event.start = exists(\"event.df\") 
    if (event.start) {
      event.start = nrow(event.df) > 0
    }
    if (event.start) {
      event.df\$END <- event.df\$ELEMENT_NAMES_NUMERIC + 1
      
      gp = gp + geom_tooltip(data = event.df, aes(x = ELEMENT_NAMES_NUMERIC, y = min(profile.df.clean\$VALUE) - y.scale, xend = END, yend = min(profile.df.clean\$VALUE) - y.scale, tooltip = EVENT, size = as.factor(7)), real.geom = geom_segment)
    
      gp = gp + scale_size_manual(name = \"Bars\", values = c(7), labels = c(\"$eventDurLegend\"))
      if ($hasColorVals) {
        colorVector <- $colorVals
        gp = gp + guides(size = guide_legend(override.aes = list(color = c(unname(colorVector[names(colorVector) == unique(event.df\$LEGEND)[1]])))))
      } else {
        gp = gp + guides(size = guide_legend(override.aes = list(color = c(the.colors[length(the.colors)]))))
      }
    }
  
  
    who_standards = exists(\"who.df\") 
    if (who_standards) {
      who_standards = nrow(who.df) > 0
    }
  
    if (who_standards){
     
       gp = gp + geom_tooltip(data=who.df,aes(x=get(myX), y=VALUE, tooltip=LEGEND),real.geom = geom_line)
     
     }
  
  
    status = exists(\"status.df\") && nrow(status.df) > 0;
  
    if (status) {
  
      if ($prtcpnt_timeline) {
  
        gp = gp + geom_tooltip(data = status.df, aes(x = ELEMENT_NAMES, y = 1, tooltip = TOOLTIP, color = COLOR, fill = FILL), size = 4, shape = 21, real.geom = geom_point)
  
        gp = gp + scale_color_manual(name=\"Legend\", breaks = $customBreaks, values=$colorVals)
        gp = gp + scale_fill_manual(name=\"\", breaks = $customBreaks, na.value = NA, values = $fillVals)
  
        if (coord.cartesian) {
          gp = gp + scale_x_date(limits=c(as.Date(x.min),as.Date(x.max)));
        }
        gp = gp + theme_bw();
        if (is.thumbnail) {
          gp = gp + labs(title=NULL, x=NULL, y=NULL);
          gp = gp + theme(legend.position = \"none\")
        } else {
          gp = gp + labs(title=\"$plotTitle\", x=myXLab, y=NULL);
          gp = gp + guides(fill = guide_legend(override.aes = list(color =\"white\" )))
          gp = gp + theme(legend.position=\"bottom\"); 
        }
        gp = gp + ylim(y.min, y.max);
        gp = gp + theme(plot.title = element_text(colour=\"#b30000\"));
  
      } else {
        status.df = transform(status.df, \"COLOR\"=ifelse(grepl(\"\\\\|\", STATUS), \"black\", as.character(STATUS)));
        status.df\$COLOR = as.character(status.df\$COLOR)
        numColors = length(unique(status.df\$COLOR))
        if (numColors > 1) {
          myColors = rainbow(numColors);
        } else {
          myColors = \"cyan\";
        }
        status.df\$TOOLTIP <- paste0(\"Day: \", status.df\$ELEMENT_NAMES_NUMERIC, \"|Status: \", status.df\$STATUS)
        status.df\$TOOLTIP[is.na(status.df\$STATUS)] <- NA      
        gp = gp + geom_tooltip(data = status.df, aes(x = ELEMENT_NAMES_NUMERIC, y = min(profile.df.clean\$VALUE) - (2 * y.scale), tooltip = TOOLTIP, color=COLOR, shape=as.factor(16)), real.geom = geom_point);
  
        if ($hasColorVals) {
          gp = gp + scale_colour_manual(values=$colorVals, breaks = $customBreaks, name=\"Legend\");
        } else {
          gp = gp + scale_colour_manual(values=c(force(the.colors), myColors), breaks=c(profile.df.full\$PROFILE_SET, status.df\$COLOR), labels=c(as.character(profile.df.full\$LEGEND), as.character(status.df\$COLOR)), name=\"Legend\");
        }
  
        #create custom legend
        gp = gp + scale_shape_manual(name=\"Points\", values=c(16), labels = c(\"$statusLegend\"));
      }
    }
  
      if (!$prtcpnt_timeline) {
        if (is.thumbnail) {
          gp = gp + labs(title=NULL, x=myXLab, y=myYLab, subtitle=\"$subtitle\");
          gp = gp + theme(plot.subtitle=element_text(size=12, color=\"black\"));
        } else {
          gp = gp + labs(title=\"$plotTitle\", x=myXLab, y=myYLab, subtitle=\"$subtitle\");
          gp = gp + theme(plot.subtitle=element_text(size=12, color=\"black\"));
        }
      }
  
      gp = gp + guides(color = guide_legend(order=1));
  
  }

  #postscript
  $rPostscript

}

if ($isWidget) {
  if (\"TOOLTIP\" %in% colnames(profile.df.full)) {
    myPlotly <- ggplotly(gp, tooltip = c(\"text\"))
  } else {
    myPlotly <- ggplotly(gp)
  }
  myPlotly <- myPlotly %>%
    add_annotations(
      yref=\"paper\", 
      xref=\"paper\", 
      y=1.05, 
      x=0, 
      text=\"$plotTitle\", 
      showarrow=F, 
      font=list(size=14,
                color=\"red\")
    ) %>% 
    layout(title=FALSE #,
    	   #legend = list(orientation = \"v\",
	#		 xanchor = \"center\",
        #                 yanchor = \"top\",
        #                 yref = \"paper\",
        #                 y = -1.3, 
        #                 x = 0.5)
    ) %>% 
    config(displaylogo = FALSE, 
           collaborate = FALSE) 
  $plotlyCustomConfig
  plotlist <- c(plotlist, tagList(myPlotly))
  #plotlist <- c(plotlist, datatable(profile.df.full))
} else {
  plotlist[[plotlist.i]] = gp;
  plotlist.i = plotlist.i + 1;
}


";
  return $rcode;
}

1;

#--------------------------------------------------------------------------------

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::ParticipantSummary;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot );
use strict;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $id = $self->getId();

  $self->setPartName('prtcpnt_sum');
  $self->setPlotTitle("Participant Observations Summary - $id");
  my $xmax = $self->getDefaultXMax() ? $self->getDefaultXMax() : 745;
  $self->setDefaultXMax($xmax);
  my $xmin = $self->getDefaultXMin() ? $self->getDefaultXMin() : 0;
  $self->setDefaultXMin($xmin);
  $self->setDefaultYMin(100);
 
  return $self;

}
1;


#--------------------------------------------------------------------------------

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::Percentile;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot );
use strict;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $id = $self->getId();

   $self->setPartName('percentile');
   $self->setDefaultYMax(100);
   $self->setDefaultYMin(0);
   $self->setYaxisLabel('Percentile');
   $self->setPlotTitle("Percentile - $id");

   $self->setIsLogged(0);

   return $self;
}
1;

#--------------------------------------------------------------------------------

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::LogRatio;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot );
use strict;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $id = $self->getId();

   $self->setDefaultYMax(2);
   $self->setDefaultYMin(-2);

   $self->setPartName('exprn_val');
   $self->setYaxisLabel("Expression Value (log2 ratio)");

   $self->setPlotTitle("Log(ratio) - $id");

   $self->setMakeYAxisFoldInduction(1);
   $self->setIsLogged(1);

   return $self;
}

1;

#--------------------------------------------------------------------------------

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::RMA;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot );
use strict;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $id = $self->getId();

  my $wantLogged = $self->getWantLogged();

  $self->setYaxisLabel("RMA Value (log2)");
  $self->setPlotTitle("RMA Expression Value - $id");
  $self->setIsLogged(1);

  # RMAExpress is log2
  if(defined($wantLogged) && $wantLogged eq '0') {
    $self->setAdjustProfile('lines.df = 2^(lines.df);points.df = 2^(points.df);stderr.df = 2^(stderr.df);');
    $self->setYaxisLabel("RMA Value");
  }

  $self->setDefaultYMax(4);
  $self->setDefaultYMin(0);

  $self->setPartName('rma');

  return $self;
}

1;

#--------------------------------------------------------------------------------

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::Filled;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot );
use strict;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $id = $self->getId();

  $self->setDefaultYMin(0);
  $self->setPartName('filled');

  $self->setIsFilled(1);
  
  return $self;
}

#--------------------------------------------------------------------------------

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::RNASeqTranscriptionSummary;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot );
use strict;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $id = $self->getId();

  $self->setPartName('transcription.summary');
  $self->setYaxisLabel('');
  $self->setPlotTitle("RNA-Seq Transcription Summary - $id");
  $self->setIsLogged(1); 
  $self->setForceNoLines(1);
  my $projectId = $self->getProject();
  my $exprMetric = "TPM";

  my $adjust = "
profile.df.full\$VALUE[profile.df.full\$VALUE < .01] <- .01
profile.df.full\$LEGEND <- as.factor(profile.df.full\$DISPLAY_NAME)
profile.df.full\$TOOLTIP <- paste(profile.df.full\$ELEMENT_NAMES, profile.df.full\$VALUE)
#exptOrder <- unique(profile.df.full\$LEGEND)
#profile.df.full <- profile.df.full[order(match(profile.df.full\$LEGEND, exptOrder), profile.df.full\$VALUE),]
profile.df.full\$LEGEND <- factor(profile.df.full\$LEGEND, levels = rev(levels(profile.df.full\$LEGEND)))

truncatedSamplesTable <- function(x,y) {
  numSamples <- length(x)
  if (numSamples > 10) { x <- x[1:10]; y <- y[1:10] }
  tableText <- paste(paste0(x, \":  \", y), collapse=\"<br>\")
  if (numSamples > 10) { tableText <- paste0(tableText, \"<br>...<br><i>(Click on points in graph to see all samples.<br> Zoom may also be necessary.)</i>\")}

  return(tableText)
}

table.df <- profile.df.full %>% 
                   group_by(LEGEND) %>% 
                   summarize(TABLE=truncatedSamplesTable(ELEMENT_NAMES, VALUE))
table.df\$TABLE <- paste0(\"<b>Sample:  $exprMetric</b><br>\", table.df\$TABLE)
profile.df.full <- merge(profile.df.full, table.df, by = 'LEGEND')
";

  $self->addAdjustProfile($adjust);

  my $plotlyConfig = "
x.max <- 1000
x.max <- max(x.max, as.numeric(profile.df.full\$VALUE + 1), na.rm = TRUE)

if (x.max > 1000) {
  x.max <- 1.2*x.max
}

myYShift <- 15
if (uniqueN(profile.df.full\$LEGEND) < 6) {
  myYShift <- 25
}

myColors <- rep(\"#38588CFF\", uniqueN(profile.df.full\$LEGEND))
myOpaqueColors <- rep(\"#38588CCC\", uniqueN(profile.df.full\$LEGEND))
myTextColors <- rep(\"white\", uniqueN(profile.df.full\$LEGEND))
colors.df <- data.table(\"LEGEND\" = unique(profile.df.full\$LEGEND), \"COLOR\" = paste0(myOpaqueColors, \"|\", myTextColors))
profile.df.full <- merge(profile.df.full, colors.df, by = \"LEGEND\")
profile.df.full\$COLOR <- paste0(profile.df.full\$COLOR, \"|\", profile.df.full\$DATASET_PRESENTER_ID)

profile.df.full.1 <- profile.df.full[profile.df.full\$LEGEND == profile.df.full\$LEGEND[length(profile.df.full\$LEGEND)],]
if (uniqueN(profile.df.full\$LEGEND) == 1) {
  profile.df.full.2 <- profile.df.full.1
} else {
  profile.df.full.2 <- profile.df.full[profile.df.full\$LEGEND != profile.df.full\$LEGEND[length(profile.df.full\$LEGEND)],]
}

myPlotly <- plot_ly(type = \"box\", data = profile.df.full.2, x = ~log2(VALUE + 1), y = ~LEGEND, color = ~LEGEND, colors = myColors, text = ~TOOLTIP, customdata = ~COLOR, hoverinfo = \"none\", boxpoints = \"all\", jitter = 0.3, pointpos = 0, showlegend = FALSE, opacity = .6, marker=list(color=\"black\")) %>% 
  add_trace(type = \"box\", data = profile.df.full.1, x = ~log2(VALUE + 1), y = ~LEGEND, color = ~LEGEND, colors = myColors, text = ~TOOLTIP, customdata = ~COLOR, hoverinfo = \"none\", boxpoints = \"all\", jitter = 0.3, pointpos = 0, showlegend = FALSE, opacity = .6, marker=list(color=\"black\"), xaxis = \"x2\") %>%
  layout(xaxis = list(title = \"\", 
		      range = c(log2(1), log2(x.max) + 2),
		      dtick = 2,
		      zerolinecolor = \"#eee\"),
	 xaxis2 = list(range = c(log2(1), log2(x.max) + 2),
		       dtick = 2,
		       zerolinecolor = \"#eee\",
		       overlaying = \"x\",
		       side = \"top\"),
         yaxis = list(visible = FALSE),
         margin = list(l = 75, 
                       r = 30, 
                       b = 75, 
                       t = 60, 
                       pad = 1),
	 boxgap = .6
  ) %>%
  add_annotations(yref=\"paper\", 
                 xref=\"paper\", 
                 y=1.075, 
                 x=-0.05, 
                 text=\"<b><i>Gene:</i></b>\", 
                 showarrow=F, 
                 font=list(size=14,
                           color=\"black\")) %>%
  add_annotations(yref=\"paper\", 
                 xref=\"paper\", 
                 y=1.075, 
                 x=0, 
                 text=\"<i>$id</i>\", 
                 showarrow=F, 
                 font=list(size=14,
                           color=\"darkred\")) %>%
  add_annotations(yref=\"paper\", 
                 xref=\"paper\", 
                 y=-0.1, 
                 x=-0.05, 
                 text=\"<i>Scale:</i>\", 
                 showarrow=F, 
                 font=list(size=14,
                           color=\"black\")) %>%
  highlight(on = \"plotly_selected\") %>%
  add_annotations(x = -.05,
                 y = unique(profile.df.full\$LEGEND),
		 text = unique(profile.df.full\$LEGEND),
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#or some similar thing to build a tooltip w a link
#R was giving me issues with special characters, may try just building w js below
#                 hovertext = paste0(
#     			 '<a href=\\'',
#         		 '#ExpressionGraphs__', 
#			 unique(profile.df.full\$DATASET_PRESENTER_ID),
#			 '\\'>Dataset Expression Graphs</a>'),
		 hovertext = unique(profile.df.full\$TABLE),
                 xref = \"paper\",
                 yref = \"y\",
                 xanchor = \"left\",
                 showarrow = FALSE,
		 font=list(size=10),
                 yshift = myYShift,
                 valign = \"top\",
		 name = unique(profile.df.full\$DATASET_PRESENTER_ID)) %>%
  config(displaylogo = FALSE, 
         collaborate = FALSE)

annotationJS <- \"function(el) {
      function getLog2(x) {
 	 return Math.log(x) / Math.log(2);
      }   
      function isEven(value) {
	if (value%2 == 0)
		return true;
	else
		return false;
      }

      //loop through experiments in plot element and get fpkm from log
      var elData = el.data;
      var xData = [];
      var xFPKM = [];
      elData.forEach(function(expt) {
  	xData.push(expt.x);
	exptFPKM = [];
        expt.x.forEach(function(x) {
	  exptFPKM.push(Math.pow(2,x)-1);
        });
	xFPKM.push(exptFPKM);
      });      

      var range = el.layout.xaxis.range;

      var annotations = el.layout.annotations;
      var linearAnnotations = [];
      linearAnnotations[1] = {
        yref: 'paper', 
        xref: 'paper', 
        y: 1.075, 
        x: -0.05, 
        text: annotations[1].text, 
        showarrow: false, 
        font: {size: 14,
               color: 'black'}
      };
      linearAnnotations[2] = {
        yref: 'paper', 
        xref: 'paper', 
        y: 1.075, 
        x: 0, 
        text: annotations[2].text, 
        showarrow: false, 
        font: {size: 14,
               color: 'darkred'}
      };
      linearAnnotations[4] = {
        yref: 'paper', 
        xref: 'paper', 
        y: -0.1, 
        x: -0.05, 
        text: annotations[4].text, 
        showarrow: false, 
        font: {size: 14,
               color: 'black'}
      };
      var i;
      for (i = 6; i < annotations.length; i++) {
        var ann = {  
          x: -0.05,
          y: annotations[i].y,
          text: annotations[i].text,
	  hovertext: annotations[i].hovertext,
          xref: 'paper',
          yref: 'y',
          xanchor: 'left',
          showarrow: false,
          font: {size: 10},
          yshift: annotations[i].yshift, 
          valign: 'top',
	  name: annotations[i].name
	};
	linearAnnotations.push(ann);
      }

	annotations.shift();

      var updatemenus =[{
        buttons: [
            {
                args: [{x: xData},
                       {xaxis: {title: '',
                                range: range,
				dtick: 2,
				zerolinecolor: '#eee'},
                        xaxis2: {title: '',
                                range: range,
                                dtick: 2,
                                zerolinecolor: '#eee',
                                overlaying: 'x',
                                side: 'top'},
			annotations: annotations}],
                label: '<i>log2($exprMetric + 1)</i>',
                method: 'update'
            },
            {
		args: [{x: xFPKM},
                       {xaxis: {title: '',
                                range: [0, Math.pow(2,range[1]-2)],
				mirror: 'ticks',
				zerolinecolor: 'eee'},
                        xaxis2: {title: '',
                                range: [0, Math.pow(2,range[1]-2)],
                                mirror: 'ticks',
                                zerolinecolor: 'eee',
                                overlaying: 'x',
                                side: 'top'},
			annotations: linearAnnotations}],
                label: '<i>$exprMetric</i>',
                method: 'update'
            }
        ],
        showactive: true,
	active: 0,
        type: 'buttons',
        y: -0.1,
	x: 0,
        direction: 'right',
	xanchor: 'left',
        yanchor: 'bottom',
	borderwidth: 2
    },
    {
        buttons: [
	    {
                args: [{annotations: el.layout.annotations}],
		label: '<i>click to remove sample labels</i>',
                method: 'relayout'
            }
        ],
        showactive: false,
        active: 0,
        type: 'buttons',
        y: -0.1,
	x: 0.85,
	xanchor: 'center',
        yanchor: 'bottom',
	bgcolor: 'lightgray',
	borderwidth: 0
    }];

    Plotly.relayout(el.id, {updatemenus: updatemenus});

      el.on('plotly_click', function(d) {
  	var ptsData = d.points[0].data;
	//console.log('Click: ', ptsData);
	
	var i;
	var annArray = [];
	var foundDup = false;
	for (i = 0; i < ptsData.customdata.length; i++) {
	  if (!(Array.isArray(ptsData.text))) {
	    ptsData.text = [ptsData.text];
	  }
	    var ann = {
              bgcolor: ptsData.customdata[i].split('|')[0],
              bordercolor: 'black',
              arrowsize: .5,
              ay: 30,
              ax: ptsData.x[i],
              axref: 'x',
              clicktoshow: 'onoff',
              font: {size: 12,
                     color: ptsData.customdata[i].split('|')[1]},
              textangle: 60,
              text: ptsData.text[i],
              x: ptsData.x[i],
              y: ptsData.y[i],
              xref: 'x',
              yref: 'y',
              xanchor: 'left',
              showarrow: true
	    };
          
          // delete instead if already exists
	  el.layout.annotations.forEach(
	    function(oldAnn, index) {
              if (ann.x === oldAnn.x && ann.y === oldAnn.y) {
                Plotly.relayout(el.id, 'annotations[' + index + ']', 'remove');
                foundDup = true;
	      }
            });
	  annArray.push(ann);
        }
	if (foundDup) return;

	Plotly.relayout(el.id, {annotations: el.layout.annotations.concat(annArray)});
      })

	//el.on('plotly_clickannotation', function(d) {
	//  console.log('Click annotation: ', d);
	//})
}\"

myPlotly <- myPlotly %>% onRender(annotationJS)

#havent yet figured how to successfully add custom css
#myPlotly <- list(
# 	      tags\$head(
#      		tags\$style(\".js-plotly-plot .plotly .modebar {left: 1%;}\")
#    	      ),
#    	      myPlotly
#	    )    
";
  $self->setPlotlyCustomConfig($plotlyConfig);
 
  return $self;
}
#--------------------------------------------------------------------------------

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::MicroarrayPercentileSummary;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot );
use strict;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $id = $self->getId();

  $self->setPartName('microarray.summary');
  $self->setYaxisLabel('');
  $self->setPlotTitle("Microarray Percentile Summary - $id");
  $self->setForceNoLines(1);
  my $projectId = $self->getProject();
  my $exprMetric = "Percentile";

  my $adjust = "
arrayTypes <- lapply(unique(profile.df.full\$DISPLAY_NAME), FUN = function(name) {ifelse(data.table::uniqueN(profile.df.full\$PROFILE_TYPE[profile.df.full\$DISPLAY_NAME == name]) > 1, 'Two Channel Array', 'One Channel Array')})
names(arrayTypes) <- unique(profile.df.full\$DISPLAY_NAME)
getArrayType <- function(name) {arrayTypes[[name]]}
profile.df.full\$LEGEND <- unlist(lapply(profile.df.full\$DISPLAY_NAME, getArrayType))
suffix <- ifelse(profile.df.full\$LEGEND == 'Two Channel Array', ifelse(profile.df.full\$PROFILE_TYPE == 'channel2_percentiles', '- channel 2', '- channel 1'), '')
profile.df.full\$LEGEND <- as.factor(paste0(profile.df.full\$LEGEND, suffix))

profile.df.full\$TOOLTIP <- paste(profile.df.full\$ELEMENT_NAMES, profile.df.full\$VALUE)
profile.df.full\$DISPLAY_NAME <- factor(profile.df.full\$DISPLAY_NAME, levels = rev(levels(as.factor(profile.df.full\$DISPLAY_NAME))))
the.colors <- rep('black', data.table::uniqueN(profile.df.full\$LEGEND))

truncatedSamplesTable <- function(x,y) {
  numSamples <- length(x)
  if (numSamples > 10) { x <- x[1:10]; y <- y[1:10] }
  tableText <- paste(paste0(x, \":  \", y), collapse=\"<br>\")
  if (numSamples > 10) { tableText <- paste0(tableText, \"<br>...<br><i>(Click on points in graph to see all samples.<br> Zoom may also be necessary.)</i>\")}

  return(tableText)
}

table.df <- profile.df.full %>% 
                   group_by(DISPLAY_NAME) %>% 
                   summarize(TABLE=truncatedSamplesTable(ELEMENT_NAMES, VALUE))
table.df\$TABLE <- paste0(\"<b>Sample:  $exprMetric</b><br>\", table.df\$TABLE)
profile.df.full <- merge(profile.df.full, table.df, by = 'DISPLAY_NAME')
";

  $self->addAdjustProfile($adjust);

  my $plotlyConfig = "
x.max <- 100

myYShift <- 15
if (uniqueN(profile.df.full\$DISPLAY_NAME) < 6) {
  myYShift <- 25
}

#reimplement w different colors once i have something working
myColors <- ifelse(profile.df.full\$LEGEND == 'One Channel Array', \"#009988\", ifelse(profile.df.full\$LEGEND == 'Two Channel Array- channel 1', \"#33BBEE\", \"#0077BB\"))
myOpaqueColors <- ifelse(profile.df.full\$LEGEND == 'One Channel Array', \"#44AA99\", ifelse(profile.df.full\$LEGEND == 'Two Channel Array- channel 1', \"#88CCEE\", \"#4A96C2\"))
myTextColors <- rep(\"black\", uniqueN(profile.df.full\$LEGEND))
colors.df <- data.table(\"LEGEND\" = unique(profile.df.full\$LEGEND), \"COLOR\" = paste0(myOpaqueColors, \"|\", myTextColors))
profile.df.full <- merge(profile.df.full, colors.df, by = \"LEGEND\")
profile.df.full\$COLOR <- paste0(profile.df.full\$COLOR, \"|\", profile.df.full\$DATASET_PRESENTER_ID)

#some bs about dual axes
profile.df.full.1 <- profile.df.full[profile.df.full\$DISPLAY_NAME == profile.df.full\$DISPLAY_NAME[length(profile.df.full\$DISPLAY_NAME)],]
if (uniqueN(profile.df.full\$DISPLAY_NAME) == 1) {
  profile.df.full.2 <- profile.df.full.1
} else {
  profile.df.full.2 <- profile.df.full[profile.df.full\$DISPLAY_NAME != profile.df.full\$DISPLAY_NAME[length(profile.df.full\$DISPLAY_NAME)],]
}

myPlotly <- plot_ly(type = \"box\", data = profile.df.full.2, x = ~VALUE, y = ~DISPLAY_NAME, color = ~LEGEND, colors = myColors, text = ~TOOLTIP, customdata = ~COLOR, hoverinfo = \"none\", boxpoints = \"all\", jitter = 0.3, pointpos = 0, showlegend = TRUE, opacity = .6, marker=list(color=\"black\")) %>% 
  add_trace(type = \"box\", data = profile.df.full.1, x = ~VALUE, y = ~DISPLAY_NAME, color = ~LEGEND, colors = myColors, text = ~TOOLTIP, customdata = ~COLOR, hoverinfo = \"none\", boxpoints = \"all\", jitter = 0.3, pointpos = 0, showlegend = FALSE, opacity = .6, marker=list(color=\"black\"), xaxis = \"x2\") %>%
  layout(xaxis = list(title = \"Percentile\", 
		      range = c(0, x.max),
		      dtick = 10,
		      zerolinecolor = \"#eee\"),
	 xaxis2 = list(range = c(0, x.max),
		       dtick = 10,
		       zerolinecolor = \"#eee\",
		       overlaying = \"x\",
		       side = \"top\"),
         yaxis = list(visible = FALSE),
         margin = list(l = 75, 
                       r = 30, 
                       b = 75, 
                       t = 60, 
                       pad = 1),
	 boxgap = .6,
         boxmode = 'group'
  ) %>%
  add_annotations(yref=\"paper\", 
                 xref=\"paper\", 
                 y=1.075, 
                 x=-0.05, 
                 text=\"<b><i>Gene:</i></b>\", 
                 showarrow=F, 
                 font=list(size=14,
                           color=\"black\")) %>%
  add_annotations(yref=\"paper\", 
                 xref=\"paper\", 
                 y=1.075, 
                 x=0, 
                 text=\"<i>$id</i>\", 
                 showarrow=F, 
                 font=list(size=14,
                           color=\"darkred\")) %>%
  highlight(on = \"plotly_selected\") %>%
  add_annotations(x = -.05,
                 y = unique(profile.df.full\$DISPLAY_NAME),
		 text = unique(profile.df.full\$DISPLAY_NAME),
		 hovertext = unique(profile.df.full\$TABLE),
                 xref = \"paper\",
                 yref = \"y\",
                 xanchor = \"left\",
                 showarrow = FALSE,
		 font=list(size=10),
                 yshift = myYShift,
                 valign = \"top\",
		 name = unique(profile.df.full\$DATASET_PRESENTER_ID)) %>%
  config(displaylogo = FALSE, 
         collaborate = FALSE)

annotationJS <- \"function(el) {
      var updatemenus =[{
        buttons: [
	    {
                args: [{annotations: el.layout.annotations}],
		label: '<i>click to remove sample labels</i>',
                method: 'relayout'
            }
        ],
        showactive: false,
        active: 0,
        type: 'buttons',
        y: -0.1,
	x: 0.85,
	xanchor: 'center',
        yanchor: 'bottom',
	bgcolor: 'lightgray',
	borderwidth: 0
    }];

    Plotly.relayout(el.id, {updatemenus: updatemenus});

      el.on('plotly_click', function(d) {
  	var ptsData = d.points[0].data;
	
	var i;
	var annArray = [];
	var foundDup = false;
	for (i = 0; i < ptsData.x.length; i++) {
	  if (!(Array.isArray(ptsData.text))) {
	    ptsData.text = [ptsData.text];
	  }
	    var ann = {
              bgcolor: ptsData.customdata[i].split('|')[0],
              bordercolor: 'black',
              arrowsize: .5,
              ay: 30,
              ax: ptsData.x[i],
              axref: 'x',
              clicktoshow: 'onoff',
              font: {size: 12,
                     color: ptsData.customdata[i].split('|')[1]},
              textangle: 60,
              text: ptsData.text[i],
              x: ptsData.x[i],
              y: ptsData.y[i],
              xref: 'x',
              yref: 'y',
              xanchor: 'left',
              showarrow: true
	    };
          
          // delete instead if already exists
	  el.layout.annotations.forEach(
	    function(oldAnn, index) {
              if (ann.x === oldAnn.x && ann.y === oldAnn.y) {
                Plotly.relayout(el.id, 'annotations[' + index + ']', 'remove');
                foundDup = true;
	      }
            });
	  annArray.push(ann);
        }
	if (foundDup) return;

	Plotly.relayout(el.id, {annotations: el.layout.annotations.concat(annArray)});
      })

}\"

myPlotly <- myPlotly %>% onRender(annotationJS)

";
  $self->setPlotlyCustomConfig($plotlyConfig);
 
  return $self;
}

#--------------------------------------------------------------------------------

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::RNASeq;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot );
use strict;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $id = $self->getId();
  my $exprMetric = $self->getExpressionMetric();
  $exprMetric = defined($exprMetric) ? $exprMetric : "tpm";

  $self->setPartName($exprMetric);
  $exprMetric = uc($exprMetric);
  $self->setYaxisLabel($exprMetric);
  $self->setPlotTitle("$exprMetric - $id");
  $self->setDefaultYMin(0);
  $self->setDefaultYMax(20);

  my $wantLogged = $self->getWantLogged();
  if(defined($wantLogged) && $wantLogged eq '1') {
    $self->addAdjustProfile('profile.df.full$VALUE <- log2(profile.df.full$VALUE + 1);');
    $self->setYaxisLabel("log2($exprMetric + 1)");
    $self->setDefaultYMax(4);
    $self->setIsLogged(1);
  }

  $self->setPointsPch(['NA']);

  $self->setSmoothLines(1);
  $self->setIsFilled(1);
  
  return $self;
}

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::RNASeqSenseAntisense;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::RNASeq );
use strict;
use Data::Dumper;

sub new {
    my ($class,$args,$profileSets) = @_;
    my $self = $class->SUPER::new($args,$profileSets);

    my $strandDictionaryHash = $self->getStrandDictionaryHash();
    my @legendNames=();
    for(my $i = 0; $i < scalar @$profileSets; $i++) {
       my $profileSet = $profileSets->[$i];
       my $profileSetName = $profileSet->getName();
       my $strandType = "";
       if ($profileSetName =~ /(\w*strande?d?)/) {
	   $strandType = $1;
       }
       my $sample = $strandDictionaryHash->{$strandType};
       if ($sample eq "sense") {
	   $sample="  sense";
	   if ($i == 1) {
	       my $newProfileSets=[];
	       $newProfileSets->[0] = $profileSets->[1];
	       $newProfileSets->[1] = $profileSets->[0];
	       $self->setProfileSets($newProfileSets);
	   }
       }
       push @legendNames, $sample; 

    }
    
    @legendNames = sort {$a cmp $b} @legendNames;
    $self->setLegendLabels(\@legendNames);
    $self->setSmoothLines(0);

    return $self;
}


#--------------------------------------------------------------------------------

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::PairedEndRNASeq;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::RNASeq );
use strict;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $id = $self->getId();
  my $exprMetric = $self->getExpressionMetric();
  $exprMetric = defined($exprMetric) ? $exprMetric : "fpkm";

  $self->setPartName($exprMetric);
  $exprMetric = uc($exprMetric);
  $self->setYaxisLabel($exprMetric);
  $self->setPlotTitle("$exprMetric - $id");

  return $self;
}


#--------------------------------------------------------------------------------

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::QuantileNormalized;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot );
use strict;

sub new {
  my $class = shift; 
   my $self = $class->SUPER::new(@_);

   my $id = $self->getId();

   $self->setDefaultYMax(4);
   $self->setDefaultYMin(0);
   $self->setYaxisLabel('Expression Value (log2)');

   $self->setPartName('exprn_val');
   $self->setPlotTitle("Expression Values (log2) - $id");

   $self->setMakeYAxisFoldInduction(0);
   $self->setIsLogged(1);

   return $self;
}

#--------------------------------------------------------------------------------

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::MRNADecay;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot );
use strict;

sub new {
  my $class = shift; 
   my $self = $class->SUPER::new(@_);

   my $id = $self->getId();

   $self->setDefaultYMax(4);
   $self->setDefaultYMin(0);
   $self->setYaxisLabel('Expression Values');

   $self->setPartName('exprn_val');
   $self->setPlotTitle("Expression Values - $id");

   $self->setMakeYAxisFoldInduction(0);
   $self->setIsLogged(0);

   return $self;
}

#--------------------------------------------------------------------------------

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::QuantMassSpec;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot );
use strict;

sub new {
  my $class = shift; 
   my $self = $class->SUPER::new(@_);

   my $id = $self->getId();

   $self->setIsLogged(1);

   $self->setDefaultYMax(1);
   $self->setDefaultYMin(-1);
   $self->setYaxisLabel('Relative Abundance (log2 ratio)');

   $self->setPartName('exprn_val');
   $self->setPlotTitle("Quant Mass Spec Profile - $id");

   $self->setMakeYAxisFoldInduction(1);


   return $self;
}

#--------------------------------------------------------------------------------

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::QuantMassSpecNonRatio;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot );
use strict;

sub new {
  my $class = shift; 
   my $self = $class->SUPER::new(@_);

   my $id = $self->getId();

   $self->setDefaultYMax(10);
   $self->setDefaultYMin(0);
   $self->setYaxisLabel('Abundance (log2)');

   $self->setPartName('exprn_val');
   $self->setPlotTitle("Quant Mass Spec Profile - $id");

   return $self;
}

#--------------------------------------------------------------------------------

package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::QuantMassSpecNonRatioUnlogged;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot );
use strict;

sub new {
  my $class = shift; 
   my $self = $class->SUPER::new(@_);

   my $id = $self->getId();

   $self->setDefaultYMax(10);
   $self->setDefaultYMin(0);
   $self->setYaxisLabel('Abundance');

   $self->setPartName('exprn_val');
   $self->setPlotTitle("Quant Mass Spec Profile - $id");

   return $self;
}


package EbrcWebsiteCommon::View::GraphPackage::GGLinePlot::LOPIT;
use base qw( EbrcWebsiteCommon::View::GraphPackage::GGLinePlot );
use strict;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);

  my $id = $self->getId();

  $self->setIsLogged(0);

  $self->setYaxisLabel("Probability");
  $self->setXaxisLabel("");
  $self->setDefaultYMax(1);
  $self->setDefaultYMin(0);

  $self->setPartName('prob');
  $self->setPlotTitle("$id");

  return $self;
}

1;
