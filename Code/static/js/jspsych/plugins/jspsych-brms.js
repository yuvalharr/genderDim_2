/*
 * Example plugin template
 */
jsPsych.plugins["bRMS"] = (function() {

  var plugin = {};

  plugin.info = {
    name: 'bRMS',
    description: '',
    parameters: {
      visUnit: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Visual unit size',
        default: 1,
        description: "Multiplier for manual stimulus size asjustment. Should be\
         depreceated with new jsPsych's native solution."
      },
      colorOpts: {
        type: jsPsych.plugins.parameterType.COMPLEX,
        pretty_name: 'Color palette',
        default: ['#FF0000', '#00FF00', '#0000FF',
          '#FFFF00', '#FF00FF', '#00FFFF'
        ],
        description: "Colors for the Mondrian"
      },
      rectNum: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Rectangle number',
        default: 500,
        description: "Number of rectangles in Mondrian"
      },
      mondNum: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Mondrian number',
        default: 50,
        description: "Number of unique mondrians to create"
      },
      stimulus_alpha: {
        type: jsPsych.plugins.parameterType.FLOAT,
        pretty_name: 'Stimulus maximum opacity',
        default: 0.5
      },
      timing_response: {
        type: jsPsych.plugins.parameterType.FLOAT,
        pretty_name: 'Timing response',
        default: 0,
        description: "Maximum time duration allowed for response"
      },
      choices: {
        type: jsPsych.plugins.parameterType.KEYCODE,
        pretty_name: 'Response choices',
        default: ['d', 'k']
      },
      stimulus_vertical_flip: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Vertical flip stimulus',
        default: 0,
      },
      fade_out_time: {
        type: jsPsych.plugins.parameterType.FLOAT,
        pretty_name: 'Fade out time',
        default: 0,
        description: "When to start fading out mask. 0 is never."
      },
      fade_in_time: {
        type: jsPsych.plugins.parameterType.FLOAT,
        pretty_name: 'Fade in time',
        default: 0,
        description: "Duration of stimulus fade in."
      },
      fade_out_length: {
        type: jsPsych.plugins.parameterType.FLOAT,
        pretty_name: 'Fade out duration',
        default: 0,
        description: "Duration of mask fade out."
      },
      within_ITI: {
        type: jsPsych.plugins.parameterType.FLOAT,
        pretty_name: 'Within plugin ITI',
        default: 0,
        description: "Duration of ITI reserved for making sure stimulus image\
         is loaded."
      },
      mond_max_alpha: {
        type: jsPsych.plugins.parameterType.FLOAT,
        pretty_name: 'Mondrian maximum contrast',
        default: 1,
        description: "Maximum contrast value for the Mondrian mask."
      },
      stimulus_side: {
        type: jsPsych.plugins.parameterType.INT,
        default: -1,
        description: "Stimulus side: 1 is right, 0 is left. -1 is random"
      },
      bigProblemDuration: {
        type: jsPsych.plugins.parameterType.INT,
        default: 100,
        description: 'If a frame is presented for more than x ms, regard the \
        trial as a big problem'
      },
      smallProblemStimDuration: {
        type: jsPsych.plugins.parameterType.INT,
        default: 40,
        description: 'Stimulus presentation criterion for small problem'
      },
      smallProblemMondDuration: {
        type: jsPsych.plugins.parameterType.INT,
        default: 50,
        description: 'Mondrian presentation criterion for small problem'
      },
      includeVBLinData: {
        type: jsPsych.plugins.parameterType.BOOL,
        default: false,
        description: 'Whether to include vbl array in data: increases memory \
        requirements.'
      }
    }
  }

  jsPsych.pluginAPI.registerPreload('bRMS', 'stimulus', 'image');

  plugin.trial = function(display_element, trial) {

    // Clear previous
    display_element.innerHTML = '';

    setTimeout(function() {

      // Start timing for within trial ITI
      var startCompute = Date.now();

      // Hide mouse
      var stylesheet = document.styleSheets[0];
      stylesheet.insertRule("* {cursor: none;}", stylesheet.cssRules.length);

      var rWidth = 6 * trial.visUnit,
        rHeight = 6 * trial.visUnit,
        fixationLength = 25 / 3 * trial.visUnit,
        fixationHeight = 2.34 * trial.visUnit,
        frameWidth = 150 * trial.visUnit,
        frameHeight = 63 * trial.visUnit,
        stimWidth = 61 * trial.visUnit,
        stimHeight = 61 * trial.visUnit;

      if (trial.stimulus_side < 0) {
        stimulus_side = Math.round(Math.random());
      } else {
        stimulus_side = trial.stimulus_side;
      }

      // this array holds handlers from setTimeout calls
      // that need to be cleared if the trial ends early
      var setTimeoutHandlers = [];

      // store response
      var response = {
        rt: -1,
        key: -1
      };

      // function to end trial when it is time
      var end_trial = function() {

        // kill the animation
        tl.kill();

        // kill any remaining setTimeout handlers
        for (var i = 0; i < setTimeoutHandlers.length; i++) {
          clearTimeout(setTimeoutHandlers[i]);
        }

        // kill keyboard listeners
        if (typeof keyboardListener !== 'undefined') {
          jsPsych.pluginAPI.cancelKeyboardResponse(keyboardListener);
        }

        // Analyse animation performance
        tvbl = {};
        tvbl['time'] = vbl['time'].filter(function(value, index) {
            return vbl['mondNum'][index] >= 0
          }),
          tvbl['mondNum'] = vbl['mondNum'].filter(function(value, index) {
            return vbl['mondNum'][index] >= 0
          }),
          tvbl['mondAlpha'] = vbl['mondAlpha'].filter(function(value, index) {
            return vbl['mondNum'][index] >= 0
          });

        tvbl['refresh'] = [];
        for (i = 0; i < tvbl['time'].length; i++) {
          tvbl['refresh'].push(tvbl['time'][i + 1] - tvbl['time'][i]);
        } // get differential time stamps

        function onlyUnique(value, index, self) {
          return self.indexOf(value) === index;
        } // get unique mondrian numbers


        mond = {}; // represent vbl per mondrian
        mond['nums'] = tvbl['mondNum'].filter(onlyUnique);

        mond['mond_duration'] = [];
        mond['stim_duration'] = [];
        for (i = 0; i < mond['nums'].length; i++) {
          mond['mond_duration'].push(tvbl['refresh'].filter(function(value, index) {
              return tvbl['mondNum'][index] == mond['nums'][i] &&
                tvbl['mondAlpha'][index] > 0
            }).reduce((a, b) => a + b, 0)),
            mond['stim_duration'].push(tvbl['refresh'].filter(function(value, index) {
              return tvbl['mondNum'][index] == mond['nums'][i] &&
                tvbl['mondAlpha'][index] == 0
            }).reduce((a, b) => a + b, 0));
        } // some vbl refresh seperately for mondrian and stim for each presentation

        bProblem = mond['nums'].filter(function(value, index) {
          return mond['mond_duration'][index] > trial.bigProblemDuration & value > 0 ||
            mond['stim_duration'][index] > trial.bigProblemDuration
        }).length; // Count instances of lag in animation

        sProblem = mond['nums'].filter(function(value, index) {
          return mond['stim_duration'][index] > trial.smallProblemStimDuration &&
            (mond['mond_duration'][index] < trial.smallProblemMondDuration ||
              mond['mond_duration'][index + 1] < trial.smallProblemMondDuration)
        }).length; // Count instances of stimulus presented for too long.

        // gather the data to store for the trial
        var trial_data = {
          "rt": response.rt,
          "stimulus": trial.stimulus,
          "stimulus_side": stimulus_side,
          "key_press": response.key,
          "acc": (response.key == 68 & stimulus_side == 0) |
            (response.key == 75 & stimulus_side == 1),
          'animation_performance': mond,
          'bProblem': bProblem,
          'sProblem': sProblem,
          'trial_began': trial_began
        };

        if (trial.includeVBLinData) {
          trial_data.vbl = vbl;
        }

        // clear the display
        display_element.innerHTML = '';

        // Return mouse
        stylesheet.deleteRule(stylesheet.cssRules.length - 1);

        // move on to the next trial
        setTimeout(function() {
          jsPsych.finishTrial(trial_data);
        }, 10);

      };

      // function to handle responses by the subject
      var after_response = function(info) {

        // only record the first response
        if (response.key == -1) {
          response = info;
        }

        end_trial();
      };

      var start_trial = function() {
        fixation.style.visibility = "visible";

        tl.play();

        // start the response listener
        if (JSON.stringify(trial.choices) != JSON.stringify(["none"])) {
          var keyboardListener = jsPsych.pluginAPI.getKeyboardResponse({
            callback_function: after_response,
            valid_responses: trial.choices,
            rt_method: 'performance',
            persist: false,
            allow_held_key: false
          });
        }
      }

      // Make display and animation -----------

      // end trial if time limit is set
      if (trial.timing_response > 0) {
        var t2 = setTimeout(function() {
          end_trial();
        }, trial.timing_response * 1000);
        setTimeoutHandlers.push(t2);
      }


      // Draw fixation
      var fixation = document.createElement('canvas');
      fixation.id = "fixation";
      fixation.className = 'jspsych-brms-frame';
      fixation.width = frameWidth;
      fixation.height = frameHeight;
      fixation.style.zIndex = 2;
      fixation.style.position = "absolute";
      fixation.style.border = "20px double #000000";
      fixation.style.visibility = "hidden";
      display_element.append(fixation);

      var fixCtx = fixation.getContext("2d");
      fixCtx.fillStyle = 'black';
      fixCtx.fillRect((frameWidth - fixationLength) / 2,
        (frameHeight - fixationHeight) / 2,
        fixationLength, fixationHeight);
      fixCtx.fillRect((frameWidth - fixationHeight) / 2,
        (frameHeight - fixationLength) / 2,
        fixationHeight, fixationLength);

      // Make mondrians
      var rectRange = [-rWidth, -rHeight,
        frameWidth + rWidth, frameHeight + rHeight
      ];
      var mondrian = [];
      for (var i = 0; i < trial.mondNum; i++) {
        mondrian.push(document.createElement('canvas'));
        mondrian[i].id = "mondrian" + i;
        mondrian[i].className = 'jspsych-brms-frame';
        mondrian[i].width = frameWidth;
        mondrian[i].height = frameHeight;
        mondrian[i].style.zIndex = 1;
        mondrian[i].style.position = "absolute";
        mondrian[i].style.border = "20px double #000000";
        mondrian[i].style.opacity = 0;
        display_element.append(mondrian[i]);

        var ctx = mondrian[i].getContext("2d");
        ctx.fillStyle = 'grey';
        ctx.fillRect(0, 0, frameWidth, frameHeight)
        // Fill rect
        for (var j = 0; j < trial.rectNum; j++) {
          ctx.fillStyle = trial.colorOpts[Math.floor(Math.random() *
            trial.colorOpts.length)];
          ctx.fillRect(Math.round(Math.random() *
              (rectRange[2] - rectRange[0]) + rectRange[0]),
            Math.round(Math.random() * (rectRange[3] - rectRange[1]) + rectRange[1]),
            rWidth + Math.round(Math.random()) * rWidth,
            rHeight + Math.round(Math.random()) * rHeight);
        }
      }

      // Draw stimulus
      var stimulus = document.createElement('canvas')
      stimulus.id = 'stimulus';
      stimulus.className = 'jspsych-brms-frame';
      stimulus.width = frameWidth;
      stimulus.height = frameHeight;
      stimulus.style.zIndex = 0;
      stimulus.style.position = "absolute";
      stimulus.style.border = "20px double #000000";
      stimulus.style.opacity = 0;
      display_element.append(stimulus);

      // Animation

      function stringSafe(n) {
        return (n < 0.00001 && n > -0.00001) ? 0 : n;
      } // Makes sure no too small values mess up the SVG animation path

      // Set up auxilllary variables
      var Hz = 60,
        trialLength = Math.max(trial.fade_out_time + trial.fade_out_length,
          trial.timing_response),
        maxFlips = trialLength * Hz,
        x, x2,
        vbl;

      // Create a timeline
      var vbl = {
          time: [],
          mondAlpha: [],
          mondNum: []
        },
        trial_began = 0,
        d = new Date(),
        j = 0,
        tl = new TimelineMax({
          paused: true,
          onUpdate: function() {
            var op1 = parseFloat(mondrian[j % trial.mondNum].style.opacity),
              op2 = parseFloat(mondrian[(j + 1) % trial.mondNum].style.opacity);
            if (op1 == 0 && op2 > 0) {
              j++
            }

            vbl['time'].push(Math.round(performance.now()));
            vbl['mondAlpha'].push(op1 + op2);
            vbl['mondNum'].push(j);
          },
          onStart: function() {
            var op1 = parseFloat(mondrian[1 % trial.mondNum].style.opacity),
              op2 = parseFloat(mondrian[(1 + 1) % trial.mondNum].style.opacity);

            trial_began = d.getTime();
            vbl['time'].push(Math.round(performance.now()));
            vbl['mondAlpha'].push(op1 + op2);
            vbl['mondNum'].push(-1);
          }
        });

      tl.to(stimulus, trial.fade_in_time, {
        opacity: trial.stimulus_alpha
      });

      /// Create mondrians alpha profile

      // Auxilllary variables
      var mondProfiles = [
        [0, 1, stringSafe(4 / maxFlips), 1, stringSafe(4 / maxFlips + 0.00001), 0]
      ];

      for (i = 6; i < maxFlips; i += 6) {

        // Compute locations
        x = stringSafe(i / maxFlips);
        x2 = stringSafe((i + 4) / maxFlips);

        var thisAlpha = Math.min(trial.mond_max_alpha,
          1 + ((maxFlips - i - 1) / Hz - (maxFlips / Hz - trial.fade_out_time)) /
          (maxFlips / Hz - trial.fade_out_time))

        // Add zero if needed
        if (mondProfiles.length - 1 < (i / 6) % trial.mondNum) {
          mondProfiles.push([0, 0])
        }

        // Push locations and values
        mondProfiles[(i / 6) % trial.mondNum].push(stringSafe(x - 0.00001), 0, x,
          thisAlpha, x2, thisAlpha, stringSafe(x2 + 0.00001), 0);
      }

      // Make into eases and add to timeline
      for (i = 0; i < mondProfiles.length; i++) {
        if (mondProfiles[i][mondProfiles[i].length - 2] > 1) {
          mondProfiles[i].splice(mondProfiles[i].length - 2, 2); //remove the last 2 points
        } else if (mondProfiles[i][mondProfiles[i].length - 2] < 1) {
          mondProfiles[i].push(1, 0);
        }

        // Create ease
        CustomEase.create("mond" + i, "M0,0 L" + mondProfiles[i].join(","));

        //Add to timeline
        tl.add(TweenMax.to(mondrian[i], trialLength, {
          opacity: trial.mond_max_alpha,
          ease: "mond" + i
        }), 0);
      }

      var stimCtx = stimulus.getContext("2d");
      if (trial.stimulus_vertical_flip) {
        stimCtx.translate(0, frameHeight);
        stimCtx.scale(1, -1);
      }
      if (stimulus_side) {
        var stimulus_location = 3 * frameWidth / 4 - frameHeight / 2;
      } else {
        var stimulus_location = frameWidth / 4 - frameHeight / 2;
      }
      var img = new Image();
      img.src = trial.stimulus;
      img.id = 'stimulusImg';
      img.onload = function() {
        stimCtx.drawImage(img, stimulus_location, 0,
          stimWidth, stimHeight);

        setTimeout(start_trial, trial.within_ITI - (Date.now() - startCompute));
      }
    }, 10);
  };

  return plugin;
})();
