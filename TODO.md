# TODO List

## UI/UX Issues (v3.0b22) - FIXED

1. ✅ GenreModeStepView: Clicking primary/secondary mode requires double-click
   - Fixed: Removed auto-advance on selection, user manually clicks Continue button

2. ✅ GenreStepView: Primary selection auto-advances instead of allowing secondary selection  
   - Fixed: Removed auto-advance when selecting first genre in primarySecondary mode
   - Only shows confirmation alert after both genres are selected (via Continue button)

3. ✅ SampleStepView: Clicking sample film requires multiple clicks to register
   - Fixed: Removed auto-advance on selection, added Continue button that respects canAdvance

4. ✅ PlotStepView: Should not use sample data, allow user to add their own plot
   - Verified: No automatic population of plot from sample movie
   - Users enter their own story details freely

## Sample Data Issues (v3.0b21)

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
