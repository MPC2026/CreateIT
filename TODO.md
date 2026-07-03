# TODO List

## Sample Data Issues

1. ✅ Fix PlotStepView sample data display
   - Previously showing beat information at the bottom of the PLOT page
   - Now shows: Name, Logline from the sample movie (beat samples removed)
   - Beat samples now only appear on the Beats page

2. ✅ Add alert on Beats page for sample beat references
   - When moving to the beats page, an alert asks if user wants sample beat information
   - If "Yes", populates each beat with sample text from the selected movie (if empty)
   - Sample beat information is displayed under each beat card

3. ✅ Ensure sample beat information matches actual sample movie
   - Beat samples are retrieved from `wizard.sampleMovie?.sample(for: beat.key)`
   - Uses the beatSamples dictionary from the selected SampleMovie
