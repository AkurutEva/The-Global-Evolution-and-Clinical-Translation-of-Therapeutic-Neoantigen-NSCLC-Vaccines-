# Refined NSCLC personalized neoantigen registry overlap figure
# Counts transcribed from the supplied figure; verify against deduplicated records.
# Install: install.packages(c('ggplot2','patchwork'))
suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
})

outdir <- 'figures/nsclc_registry_overlap_refined'
dir.create(outdir, recursive=TRUE, showWarnings=FALSE)

# INPUTS: replace with validated record-level cross-registry matching results.
ctg_only <- 19L
both <- 16L
who_only <- 4L
status_differences <- 11L
phase_format_differences <- 16L
accrual_differences <- 2L

N <- ctg_only + both + who_only
stopifnot(N == 39L)
ctg <- ctg_only + both
who <- who_only + both
pct <- function(n) sprintf('%.1f%%', 100*n/N)

navy <- '#1D3C63'; blue <- '#32669B'; teal <- '#147D78'
ink <- '#17273D'; mute <- '#54677D'; rule <- '#DEE6EE'

# Visual circles are schematic, not area-proportional to the set sizes.
circle_df <- function(cx, cy, r, n=600) {
  a <- seq(0, 2*pi, length.out=n)
  data.frame(x=cx+r*cos(a), y=cy+r*sin(a))
}
left <- circle_df(-0.64,0,1.52)
right <- circle_df(0.72,0,1.32)

venn <- ggplot() +
  geom_polygon(data=left,aes(x,y),fill=blue,alpha=.20,colour=navy,linewidth=1.15) +
  geom_polygon(data=right,aes(x,y),fill=teal,alpha=.20,colour=teal,linewidth=1.15) +
  annotate('text', x=-1.15,y=1.84,label='ClinicalTrials.gov',fontface='bold',size=5.0,colour=navy) +
  annotate('text', x=-1.15,y=1.61,label=paste0('n = ',ctg,'  |  ',pct(ctg)),size=3.8,colour=navy) +
  annotate('text', x=1.25,y=1.65,label='WHO ICTRP',fontface='bold',size=5.0,colour=teal) +
  annotate('text', x=1.25,y=1.43,label=paste0('n = ',who,'  |  ',pct(who)),size=3.8,colour=teal) +
  annotate('text',x=-1.45,y=.25,label=ctg_only,size=12,fontface='bold',colour=navy) +
  annotate('text',x=-1.45,y=-.15,label=paste0('CT.gov only\n',pct(ctg_only)),size=3.8,fontface='bold',lineheight=1.35,colour=ink) +
  annotate('text',x=.03,y=.25,label=both,size=12,fontface='bold',colour=ink) +
  annotate('text',x=.03,y=-.15,label=paste0('In both sources\n',pct(both)),size=3.8,fontface='bold',lineheight=1.35,colour=ink) +
  annotate('text',x=1.48,y=.25,label=who_only,size=12,fontface='bold',colour=teal) +
  annotate('text',x=1.48,y=-.15,label=paste0('ICTRP only\n',pct(who_only)),size=3.8,fontface='bold',lineheight=1.35,colour=ink) +
  coord_equal(xlim=c(-2.55,2.50),ylim=c(-1.58,2.05),expand=FALSE,clip='off') +
  labs(title='Registry overlap of personalized neoantigen vaccine trials in NSCLC',
       subtitle='ClinicalTrials.gov and WHO ICTRP  |  39 unique trial records in the deduplicated analysis') +
  theme_void(base_size=13) +
  theme(plot.title=element_text(face='bold',size=16,colour=ink,hjust=.5,margin=margin(b=5)),
        plot.subtitle=element_text(size=10.5,colour=mute,hjust=.5,margin=margin(b=12)),
        plot.margin=margin(14,28,8,28))

# Clean summary panel uses concise claims and separates presentation differences
# from substantive discordance. No unsupported causal interpretations.
card_data <- data.frame(
  x=c(1,2,3),
  heading=c('REGISTRY COVERAGE','MATCHED-RECORD AUDIT','INTERPRETATION'),
  lines=c(
    paste0('ClinicalTrials.gov: ',ctg,' / ',N,' (',pct(ctg),')\nWHO ICTRP: ',who,' / ',N,' (',pct(who),')\nFound in both: ',both,' / ',N,' (',pct(both),')'),
    paste0('Status differences: ',status_differences,' / ',both,'\nPhase notation differences: ',phase_format_differences,' / ',both,'\nEnrollment differences: ',accrual_differences,' / ',both),
    'Searching both sources added 4 records\nnot identified in the CT.gov-only set.\nReview matched entries before synthesis.'
  ), stringsAsFactors=FALSE
)

cards <- ggplot(card_data,aes(x=x,y=1)) +
  geom_tile(width=.96,height=.91,fill='#F5F8FB',colour=rule,linewidth=.7) +
  geom_tile(aes(y=1.33),width=.96,height=.25,fill=c(navy,navy,teal),show.legend=FALSE) +
  geom_text(aes(y=1.33,label=heading),fontface='bold',colour='white',size=3.45) +
  geom_text(aes(y=1.11,label=lines),vjust=1,hjust=.5,lineheight=1.55,colour=ink,size=3.25) +
  coord_cartesian(xlim=c(.49,3.51),ylim=c(.52,1.49),expand=FALSE,clip='off') +
  theme_void() + theme(plot.margin=margin(0,15,0,15))

figure <- venn / cards + plot_layout(heights=c(3.1,1.30)) +
  plot_annotation(caption=paste0(
    'Counts from the deduplicated cross-registry analysis (N = 39; FRAME-001 harmonized into both sources). Percentages use the deduplicated total. ',
    'WHO ICTRP indexes records from multiple registries; appearing in both sources does not mean two independent registrations.\n',
    'Phase notation differences are formatting differences unless substantive phase disagreement is confirmed. ',
    'Reconcile registry identifiers, statuses, and update dates before publication.'),
    theme=theme(plot.caption=element_text(size=8.5,colour=mute,hjust=.5,
                                         margin=margin(t=12,b=9,l=15,r=15)),
                plot.background=element_rect(fill='white',colour=NA)))

ggsave(file.path(outdir,'registry_overlap_refined.png'),figure,width=13.5,height=9.3,dpi=600,bg='white')
ggsave(file.path(outdir,'registry_overlap_refined.pdf'),figure,width=13.5,height=9.3,device='pdf',bg='white')
if (requireNamespace('svglite',quietly=TRUE))
  ggsave(file.path(outdir,'registry_overlap_refined.svg'),figure,width=13.5,height=9.3,device=svglite::svglite)

write.csv(data.frame(group=c('ClinicalTrials.gov only','Both sources','WHO ICTRP only'),
                     trials=c(ctg_only,both,who_only),
                     percentage=c(100*ctg_only/N,100*both/N,100*who_only/N)),
          file.path(outdir,'registry_overlap_counts.csv'),row.names=FALSE)
message('Wrote figures to: ',outdir)
