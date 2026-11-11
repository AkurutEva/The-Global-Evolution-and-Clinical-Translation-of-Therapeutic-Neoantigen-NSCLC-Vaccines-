# NSCLC-only trial starts: annual and cumulative trends (1991-2026)
# Three descriptively labelled eras; annual numbers rendered above both trend lines.
# Run: Rscript plot_nsclc_three_eras_readable_labels.R
# install.packages(c('ggplot2','dplyr','tidyr','readr','patchwork'))
suppressPackageStartupMessages({library(ggplot2);library(dplyr);library(tidyr);library(readr);library(patchwork)})
args <- commandArgs(trailingOnly=FALSE)
sarg <- grep('^--file=',args,value=TRUE)
folder <- if(length(sarg)) dirname(normalizePath(sub('^--file=','',sarg[1]))) else getwd()
input <- file.path(folder,'vaccine_temporal_trend_data_cleaned.csv')
if(!file.exists(input)) input <- 'vaccine_temporal_trend_data_cleaned.csv'
stopifnot(file.exists(input))
raw <- read_csv(input,show_col_types=FALSE)
nsclc <- raw %>% filter(Vaccine_Type %in% c('NSCLC Non-Neoantigen Vaccine','Neoantigen Vaccines (NSCLC)')) %>%
  distinct(TrialID,.keep_all=TRUE) %>%
  mutate(Year=as.integer(Year), Type=if_else(Vaccine_Type=='Neoantigen Vaccines (NSCLC)','Neoantigen','Non-neoantigen'))
stopifnot(nrow(nsclc)==185,n_distinct(nsclc$TrialID)==185)
annual <- nsclc %>% count(Year,Type,name='n') %>%
  complete(Year=seq(min(nsclc$Year),max(nsclc$Year)),Type=c('Non-neoantigen','Neoantigen'),fill=list(n=0))
wide <- annual %>% pivot_wider(names_from=Type,values_from=n) %>% arrange(Year) %>%
  mutate(Total=`Non-neoantigen`+Neoantigen,
         Total_MA3=(Total+lag(Total)+lag(Total,2))/3,
         Neo_MA3=(Neoantigen+lag(Neoantigen)+lag(Neoantigen,2))/3,
         Cum_Total=cumsum(Total),Cum_Non=cumsum(`Non-neoantigen`),Cum_Neo=cumsum(Neoantigen))
stopifnot(sum(wide$`Non-neoantigen`)==145,sum(wide$Neoantigen)==40)
navy <- '#203F65'; teal <- '#15877D'; coral <- '#C5574A'; purple <- '#6B2E98'
# Place the non-neoantigen segment on bottom and the neoantigen segment on top.
bar <- annual %>% mutate(Type=factor(Type,levels=c('Non-neoantigen','Neoantigen'))) %>%
  left_join(wide %>% select(Year,Non=`Non-neoantigen`),by='Year') %>%
  mutate(label_y=if_else(Type=='Non-neoantigen',n/2,Non+n/2),
         label=if_else(n>0,as.character(n),''))
pre_labels <- wide %>% filter(Year<2016,Total>0)
periods <- data.frame(xmin=c(1990.5,2015.5),xmax=c(1999.5,2026.5),shade=c('#EAF3FA','#FAEFED'))
xbreaks <- c(1991,1995,2000,2005,2010,2015,2016,2020,2025,2026)
base_layers <- list(
  geom_rect(data=periods[1,,drop=FALSE],aes(xmin=xmin,xmax=xmax,ymin=-Inf,ymax=Inf),fill='#EAF3FA',inherit.aes=FALSE),
  geom_rect(data=periods[2,,drop=FALSE],aes(xmin=xmin,xmax=xmax,ymin=-Inf,ymax=Inf),fill='#FAEFED',inherit.aes=FALSE),
  geom_vline(xintercept=2016,linetype='longdash',color=coral,linewidth=.6),
  scale_x_continuous(limits=c(1990.4,2030.5),breaks=xbreaks,expand=c(0,0)),
  theme_classic(base_size=10),
  theme(panel.grid.major.y=element_line(color='#E8EDF2',linewidth=.3),axis.text.x=element_text(size=9),
        axis.title=element_text(face='bold'),plot.title=element_text(color=navy,face='bold',size=12),
        legend.position='bottom',legend.direction='horizontal',legend.box='horizontal',legend.key.width=grid::unit(1.7,'cm'),plot.margin=margin(14,24,14,14)))
pa <- ggplot() + base_layers +
  geom_col(data=bar,aes(x=Year,y=n,fill=Type),width=.76,position=position_stack(reverse=TRUE)) +
  # Draw moving-average curves BEFORE count labels so text remains on top.
  geom_line(data=wide,aes(x=Year,y=Total_MA3,color='All trials (3-year mean)'),linewidth=1.08,na.rm=TRUE) +
  geom_line(data=wide %>% filter(Year>=2016),aes(x=Year,y=Neo_MA3,color='Neoantigen (3-year mean)'),
            linewidth=1.35,linetype='longdash',na.rm=TRUE) +
  geom_point(data=wide %>% filter(Year>=2016 & !is.na(Neo_MA3)),
             aes(x=Year,y=Neo_MA3),color=purple,fill='white',shape=21,size=1.8,stroke=.65) +
  # Label all nonzero early totals with a light backing to protect legibility at intersections.
  geom_label(data=pre_labels,aes(x=Year,y=Total+.36,label=Total),
             size=2.75,color=navy,fontface='bold',fill='white',
             label.size=NA,label.padding=grid::unit(.05,'lines')) +
  # After 2016 label *each* nonzero category, never just their sum.
  # Same-colour backing preserves readability wherever lines cross a number.
  geom_label(data=bar %>% filter(Year>=2016,n>0),
             aes(x=Year,y=label_y,label=label,fill=Type),
             color='white',size=3,fontface='bold',label.size=NA,
             label.padding=grid::unit(.06,'lines')) +
  annotate('label',x=1995.5,y=14.55,label='Early period (before 2000)',
           fill='white',color=navy,size=2.9,label.size=0) +
  annotate('label',x=2007.5,y=14.55,label='Non-neoantigen expansion (2000–2015)',
           fill='white',color=navy,size=2.9,label.size=0) +
  annotate('label',x=2021.0,y=14.55,label='Neoantigen era (2016 onward)',
           fill='white',color=coral,size=2.9,label.size=0) +
  scale_fill_manual(values=c('Non-neoantigen'=teal,'Neoantigen'=coral),name=NULL) +
  scale_color_manual(values=c('All trials (3-year mean)'=navy,'Neoantigen (3-year mean)'=purple),name=NULL) +
  coord_cartesian(ylim=c(0,15.8),clip='off') +
  labs(title='A  |  Annual NSCLC vaccine trial starts',subtitle='Bar labels show annual totals before 2016, and separate vaccine-type counts from 2016 onward',
       x=NULL,y='Annual trials (n)') + guides(fill=guide_legend(order=1,nrow=1,byrow=TRUE),color=guide_legend(order=2,nrow=1,byrow=TRUE))
cumulative <- wide %>% select(Year,`All trials`=Cum_Total,`Non-neoantigen`=Cum_Non,Neoantigen=Cum_Neo) %>%
  pivot_longer(-Year,names_to='Series',values_to='Cumulative')
ends <- cumulative %>% filter(Year==max(Year))
first_neo <- min(wide$Year[wide$Neoantigen>0]); first_n <- wide$Cum_Neo[wide$Year==first_neo]
pb <- ggplot() + base_layers +
  geom_line(data=cumulative,aes(Year,Cumulative,color=Series),linewidth=1.14) +
  geom_point(data=ends,aes(Year,Cumulative,color=Series),size=2.3) +
  geom_text(data=ends,aes(Year+.28,Cumulative,label=paste0(Series,'  ',Cumulative),color=Series),hjust=0,fontface='bold',size=3.1) +
  geom_point(aes(x=first_neo,y=first_n),shape=21,fill=coral,color='white',size=3) +
  annotate('label',x=2020.2,y=51,label=paste0('First NSCLC neoantigen trials\n(',first_neo,'; n=',first_n,')'),
           color=coral,fill='white',size=3,fontface='bold',label.size=.2) +
  annotate('segment',x=2018.6,y=44,xend=first_neo+.15,yend=first_n+2.5,
           arrow=arrow(length=grid::unit(.12,'in')),color=coral,linewidth=.6) +
  annotate('label',x=1995.5,y=196,label='Early period (before 2000)',fill='white',color=navy,size=2.9,label.size=0) +
  annotate('label',x=2007.5,y=196,label='Non-neoantigen expansion (2000–2015)',fill='white',color=navy,size=2.9,label.size=0) +
  annotate('label',x=2021,y=196,label='Neoantigen era (2016 onward)',fill='white',color=coral,size=2.9,label.size=0) +
  scale_color_manual(values=c('All trials'=navy,'Non-neoantigen'=teal,'Neoantigen'=coral),guide='none') +
  coord_cartesian(ylim=c(0,207),clip='off') +
  labs(title='B  |  Cumulative NSCLC vaccine trial starts',x='Trial start year',y='Cumulative trials (n)')
fig <- ((pa/pb) + plot_layout(heights=c(1.04,1),guides='collect') +
  plot_annotation(title='NSCLC vaccine clinical trial landscape | 1991–2026',
    subtitle='N = 185 unique NSCLC trial IDs  •  145 non-neoantigen  •  40 neoantigen',
    caption='Source: cleaned trial dataset. Annual counts based on trial start year. Trailing 3-year moving averages; 2016 marks first recorded NSCLC neoantigen trials.',
    theme=theme(plot.title=element_text(size=16,face='bold',color=navy),plot.subtitle=element_text(color='#54677C'),plot.caption=element_text(size=8,color='#54677C')))) & theme(legend.position='bottom',legend.direction='horizontal')
ggsave(file.path(folder,'nsclc_three_eras_readable_labels.png'),fig,width=17,height=11.3,dpi=600,bg='white')
ggsave(file.path(folder,'nsclc_three_eras_readable_labels.pdf'),fig,width=17,height=11.3,bg='white')
write_csv(wide,file.path(folder,'nsclc_three_eras_annual_counts.csv'))
message('Saved NSCLC-only 3-era figure and annual counts.')
