// Parameters
var ITI = 1000,
  time_limit = 60 * (60 * 1000),
  stimAlphas = 0.4,
  unitSize = 4,
  breakEvery = 50,
  exp_num_faces = 50, // number of different faces to use per experiment  *yuval
  repetitions = 4, // number of repetitions of each face   *yuval
  total_num_faces = 300, // total number of faces in the database (e.g 300- for one gender only) (images file) *yuval
  train_repetitions = 3,
  train_alpha = 0.4,
  trialLength = 0, // 0 is no limit
  fade_in_time = 1,
  fade_out_time = 15,
  fade_out_length = 5,
  training_allowed_repeat = 1,
  experiment_performance_thresh = .85,
  experiment_performance_trials = 20,
  train_performance_thresh = .5,
  experiment_RT_trials = 8,
  experiment_RT_trial_threshold = 5,
  experiment_RT_threshold = 300,
  sProblemCrit = 8,
  bProblemCrit = 2;

/*** Male / Female condition ***/
// Now comes from Psiturk
 var condition = Math.round(Math.random()); // 0 is male, 1 is female. Resolved here now, later from Psiturk or prolific

/*** Enter fullscreen ***/
var fullscreen = {
  type: 'fullscreen',
  fullscreen_mode: true,
  message: '<p>This study runs in fullscreen. To switch to full screen mode \
  and start the HIT, press the button below.</p>'
}

/** 1----coin instructions**/

var images = ['../static/images/Nickel.png',
  '../static/images/Penny.png',
  '../static/images/Dime.png',
  '../static/images/Quarter.png',
  '../static/images/keys.jpg',
  '../static/images/coin_demo.jpg'
];

// Initiate psiturk
// 
// var psiturk = new PsiTurk(uniqueId, adServerLoc, mode);

/*** Instructions ***/
var preCalibInsText = [{
    stimulus: ["<div class='center'>Welcome to the study!<br> \
    <p>Your participation will help us investigate human precision and reaction-times in dynamic environments.</p>\
    <p>Please read the instructions carefully.</p>\
    <p align='center'><i>Press the space bar to continue.</i></p></div>"],
    choices: [32]
  },
  {
    stimulus: ["<div class='center'><p>We will begin by calibrating the experiment \
      for the size of your screen.</p>\
      <p>After this short calibration, we will continue to the main task for \
      this study.</p>\
      <p align='center'><i>Press the space bar to continue.</i></p></div>"],
    choices: [32]
  },
  {
    stimulus: ["<div class='center'><p>For the calibration stage, you will need a coin.</p>\
      <p>Any US coin will do.</p>\
      <p align='center'><i>Press the space bar to continue.</i></p></div>"],
    choices: [32]
  },
  {
    stimulus: ["<div class='center'><img src='../static/images/coin_demo.jpg' height='400'></img>\
      <p>You will be asked to position the coin\
      as shown in the picture. You will place it against your screen,\
      within an empty circle presented to you.</p>\
      <p align='center'><i>Press the space bar to continue.</i></p></div>"],
    choices: [32]
  },
  {
    stimulus: ["<div class='center'><p>Using the up and down arrow keys, \
      you will then adjust the size of the empty circle, so that it matches the \
      size of your coin.</p>\
      <p align='center'><i>Press the space bar to continue.</i></p></div>"],
    choices: [32]
  },
  {
    stimulus: ["<div class='center'><p>Take your time in doing so, as this measurement\
      will be used throughout the study to make sure images are presented to \
      you in their correct size.</p>\
      <p>When you are done adjusting the circle size, press the space bar to \
      continue to the main task.\
      <p align='center'><i>Press the space bar to continue.</i></p></div>"],
    choices: [32]
  },
  {
    stimulus: ["<div class='center'><p>Please have a coin at hand.</p>\
      <p>Press the space bar to start the calibration stage.</p></div>"],
    choices: [32]
  }
];

var preCalibIns = {
  type: 'html-keyboard-response',
  timeline: preCalibInsText,
  timing_post_trial: 400
};

/** 2-------- coin calibration**/

/*** Screen calibration size ***/
// Define global variables for this calibration
var coins = ['Penny', 'Nickel', 'Dime', 'Quarter'];
var sizes = [19.05, 21.209, 17.907, 24.257]; // Coin sizes in mm
var whichCoin = '';
var coinInd = NaN;

// Define choose coin trial
var chooseCoin = {
  type: 'html-button-response',
  stimulus: 'Using the mouse, select the coin you would like to use:',
  choices: coins,
  button_html: ['<div class="coin"><input type="image" src="../static/images/Penny.png" width="100" name="penny"></input><label for="penny" class="coin_label">Penny</label></div>',
    '<div class="coin"><input type="image" src="../static/images/Nickel.png" width="111" name="nickel"></input><label for="nickel" class="coin_label">Nickel</label></div>',
    '<div class="coin"><input type="image" src="../static/images/Dime.png" width="94" name="dime"></input><label for="dime" class="coin_label">Dime</label></div>',
    '<div class="coin"><input type="image" src="../static/images/Quarter.png" width="127" name="quarter"></input><label for="quarter" class="coin_label">Quarter</label></div>'
  ],
  on_finish: function(data) {
    whichCoin = coins[data.button_pressed];
    coinInd = data.button_pressed;
  },
  timing_post_trial: 200
};

// Define single iteration of coin size calibration
var calibrate_trial = {
  type: 'html-keyboard-response',
  prompt: ['<p>Place your coin within the empty circle, touching the bottom line.<br>\
  Adjust the circle size with the up and down arrow keys until it fits your coin.</p>\
  <p align="center"><i>Press the space bar when you are done.</i></p>\
  <p align="center"><i>Press the r key to change a coin type.</i></p>'],
  stimulus: function() {
    var coinSize = unitSize * sizes[coinInd];
    return x = '<svg style="block: inline" width="800" height="300">\
  <circle cx="200" cy="' + (250 - coinSize / 2) + '" r="' + coinSize / 2 +
      '" stroke="black" stroke-width="2" fill="grey" />\
  <line x1="0" y1="250" x2="1000" y2="250" style="stroke:black;stroke-width:2" />\
  <image x="' + (600 - coinSize / 2) + '" y="' + (250 - coinSize) + '" width="' + (coinSize) +
      '" height="' + (coinSize) + '" style:"block: inline" xlink:href="../static/images/' +
      whichCoin + '.png"></image>\
    <circle cx="600" cy="' + (250 - coinSize / 2) + '" r="' + coinSize / 2 +
      '" stroke="black" stroke-width="2" fill-opacity="0" />\
</svg>';
  },
  choices: [38, 40, 32, 82],
  timing_post_trial: 0
}

// Define loop of coin size calibration
var adjustCoin = {
  timeline: [calibrate_trial],
  loop_function: function() {
    switch (jsPsych.data.get().last(1).select('key_press').values[0]) {
      case 38:
        // Normalize step size to size of the penny.
        unitSize += (.2 / (sizes[coinInd] / sizes[0]));
        return true;
        break;
      case 40:
        unitSize -= (.2 / (sizes[coinInd] / sizes[0]));
        return true;
        break;
      default:
        return false;
    }
  }
}

var makeSure = {
  type: 'html-keyboard-response',
  prompt: ['<p style="line-height: 56px"><b>Are you sure the circle is as close as can be around your coin?</b></p>\
  <p align="center"><i>Press the space bar if you are sure.</i></p>\
  <p align="center"><i>Press the r key to start again.</i></p>'],
  stimulus: function() {
    var coinSize = unitSize * sizes[coinInd];
    return x = '<svg style="block: inline" width="800" height="300">\
  <circle cx="200" cy="' + (250 - coinSize / 2) + '" r="' + coinSize / 2 +
      '" stroke="red" stroke-width="2" fill="grey" />\
  <line x1="0" y1="250" x2="1000" y2="250" style="stroke:red;stroke-width:2" />\
  <image x="' + (600 - coinSize / 2) + '" y="' + (250 - coinSize) + '" width="' + (coinSize) +
      '" height="' + (coinSize) + '" style:"block: inline" xlink:href="../static/images/' +
      whichCoin + '.png"></image>\
    <circle cx="600" cy="' + (250 - coinSize / 2) + '" r="' + coinSize / 2 +
      '" stroke="red" stroke-width="2" fill-opacity="0" />\
</svg>';
  },
  choices: [32, 82],
  timing_post_trial: 200
}

// Nest in another loop to allow returning and changing coin
var initialSizeCalib = {
  timeline: [chooseCoin, adjustCoin],
  loop_function: function() {
    switch (jsPsych.data.get().last(1).select('key_press').values[0]) {
      case 82:
        return true;
        break;
      default:
        return false;
    }
  }
};

var makeSureLoop = {
  timeline: [initialSizeCalib, makeSure],
  loop_function: function() {
    switch (jsPsych.data.get().last(1).select('key_press').values[0]) {
      case 82:
        return true;
        break;
      default:
        return false;
    }
  }
};


/** 3------- PRACTICE INSTRUCTIONS ***/
// Change instructions according to condition
if (condition == '1') {
  var gender = 'female';
  var person = 'woman';
  var mersons = 'women';
} else {
  var gender = 'male';
  var person = 'man';
  var mersons = 'men';
}

var instruction_text = [{
    stimulus: ["<p>We will now continue to the main task.</p>\
    <p align='center'><i>Press the space bar to continue.</i></p>"],
    choices: [32]
  },
  {
    stimulus: ["<div class = 'center'><p>You will be presented with rapidly \
      changing patterns of rectangles. Through these rectangles, " +
      gender +
      " faces will appear. Your task will be to indicate the location of \
      the faces, or any part of them, as soon as they appear.</p>\
      <p align='center'><i>Press the space bar to continue.</i></p></div>"
    ],
    choices: [32]
  },
  {
    stimulus: ["<div class = 'center'><p>If a " +
      person + "'s face appeared in the right half \
      of the screen, press the right key. If a " +
      person + "'s face appeared in the left half \
      of the screen, press the left key.</p>\
      <p align='center'><i>Press the space bar to continue.</i></p></div>"
    ],
    choices: [32]
  },
  {
    stimulus: ["<div class = 'center'><p>Please perform this task as accurately \
      and quickly as you can.</p>\
      <p align='center'><i>Press the space bar to continue.</i></p></div>"],
    choices: [32]
  },
  {
    stimulus: ["<div class = 'center'><p>During the task, please focus your gaze at\
       the plus sign in the middle.<br>Even though the faces appear to the left\
        and right of the plus sign, it is important that you look at the plus \
        sign at all times.</p>\
        <p align='center'></i>Press the space bar to continue.</i></p></div>"],
    choices: [32]
  },
  {
    stimulus: ["<div class='center'>\
      <img src='../static/images/keys.jpg'></img>\
      <p>Place your fingers on the 'D' and 'K' keys as shown in the picture, \
      and press either one of these keys to continue.</p></div>"],
    choices: [68, 75]
  }
];

var instructions = {
  type: 'html-keyboard-response',
  timeline: instruction_text,
  timing_post_trial: 200
};


/** 4----- PRACTICE BLOCK  **/

/*** bRMS practice block ***/
//Define stimuli pool for experiment
var all_images = [];
// Choose male / female files
if (condition == '1') {
  var gender = 'f';
} else {
  var gender = 'm';
}
for (i = 1; i <= total_num_faces; i++) { //creating an array of all possible images names    *yuval
  all_images.push('../static/images/' + gender + ('000' + i).substr(-3, 3) + '.jpg');
}
all_images = jsPsych.randomization.shuffle(all_images); //after shuffling, the chosen images will be taken from this 'all_images' array. *yuval



// Define stimuli for practice
var pre_practice_stimuli = all_images;
pre_practice_stimuli = pre_practice_stimuli.slice(0, train_repetitions); //take first images for practice (not sure if 'pre' array neccesary but works well)  *yuval
var practice_stimuli = [];

for (i = 0; i < train_repetitions; i++) {
  practice_stimuli.push({
    stimulus: pre_practice_stimuli[i],
    data: {
      stimulus: pre_practice_stimuli[i],
      stimulus_type: 'normal',
      timing_response: trialLength,
      fade_out_time: fade_out_time,
      fade_in_time: fade_in_time,
      fade_out_length: fade_out_length,
      stimulus_alpha: train_alpha
    },
    timing_response: trialLength,
    fade_out_time: fade_out_time,
    fade_in_time: fade_in_time,
    fade_out_length: fade_out_length,
    stimulus_alpha: train_alpha
  });
}

all_images = all_images.slice(train_repetitions, train_repetitions + exp_num_faces); //getting rid of images used in practice


/* define block */
var bRMS_practice = {
  type: "bRMS",
  timeline: practice_stimuli,
  timing_post_trial: 100,
  visUnit: function() {
    return unitSize
  },
  within_ITI: ITI - 100
};

var performanceMSG_practice = {
    type: 'html-keyboard-response',
    stimulus: ["<div class='center'>\
  <p>You pressed the wrong key too many times during the practice block.</p>\
  <p>Press either the 'D' or 'K' keys to repeat it.</p></div>"],
    choices: [68, 75],
    on_start: function(trial) {
      if (jsPsych.data.get().last(1).select('trial_type').values != 'bRMS') {
        trial.stimulus = '';
        trial.choices = jsPsych.NO_KEYS;
        trial.trial_duration = 0;
      }
    }
  },
  stop_practice_loop = {
    type: 'html-keyboard-response',
    conditional_function: function() {
      if (jsPsych.data.get().last(1).select('train_repeats').values[0] > training_allowed_repeat) {
        return true;
      } else {
        return false;
      }
    },
    timeline: [{
      stimulus: "<div class='center'>\
  <p>It seems that you are not performing the task as instructed.</p>\
  <p>Please return this HIT.</p>\
  <p>If you feel that this is a mistake, please email \
  yaniv.abir+mturk@mail.huji.ac.il</p>\
  <p>Press the space bar to continue.</p></div>"
    }],
    choices: [32],

    //** needed eventualy **//
    on_finish: function() {
      psiturk.saveData({
        success: function() {
          jsPsych.endExperiment('The experiment has been aborted. Please return HIT.');
        }
      });
    },
  }



jsPsych.data.addProperties({
  train_repeats: 1
});

var secChanceLoop = {
  timeline: [performanceMSG_practice, bRMS_practice, stop_practice_loop],
  loop_function: function() {
    if (jsPsych.data.get().last(train_repetitions).select('acc').mean() < train_performance_thresh) {
      jsPsych.data.addProperties({
        train_repeats: jsPsych.data.get().last(1).select('train_repeats').values[0] + 1
      });
      return true
    } else {
      return false
    }
  }
};


//** 5------main block instructions **//

var mainBlockText = [{
    stimulus: ["<div class = 'center'><p>You have completed the practice block.</p>\
  <p>You will now continue with the same task. The task may now be more \
  difficult.\
  You will have 3 short breaks. </p>\
    <p>Press either the 'D' or the 'K' keys to continue.</p></div>"],
    choices: [68, 75]
  },
  {
    stimulus: ["<div class = 'center'><p>During the task, please focus your gaze at\
   the plus sign in the middle.<br>Even though the faces appear to the left\
    and right of the plus sign, it is important that you look at the plus \
    sign at all times.</p>\
    <p>Press either the 'D' or the 'K' keys to continue.</p></div>"],
    choices: [68, 75]
  }
]

var mainBlockIns = {
  type: 'html-keyboard-response',
  timeline: mainBlockText,
  timing_post_trial: 200
}

//** 6------------brms main block**//

// Define stimuli for bRMS


var used_images = all_images.slice(0, exp_num_faces); //creating 'used_images[]', holding all and only faces going to be used in the main block. *yuval
var stimuli = [];


for (i = 0; i < repetitions; i++) { // Create a list of trials, repeating the experiment block x amount of times. *yaniv
  used_images = jsPsych.randomization.shuffle(used_images); //shuffling again for next repeats  *yuval
  for (ii = 0; ii <= exp_num_faces - 1; ii++) {
    stimuli.push({
      type: "bRMS",
      stimulus: used_images[ii],
      data: {
        stimulus: used_images[ii],
        timing_response: trialLength,
        stimulus_alpha: stimAlphas,
        timing_post_trial: 100,
        within_ITI: ITI - 100,
        fade_in_time: fade_in_time,
        fade_out_time: fade_out_time,
        fade_out_length: fade_out_length,
        trial: (i * exp_num_faces) + ii + 1 // set trial number in data (example: 301,302...) *yuval
      },
      stimulus_alpha: stimAlphas,
      timing_post_trial: 100,
      within_ITI: ITI - 100,
      timing_response: trialLength,
      fade_in_time: fade_in_time,
      fade_out_time: fade_out_time,
      fade_out_length: fade_out_length
    });
  }
}


/* Add breaks */
var breakMsg = {
  type: "html-keyboard-response",
  stimulus: ["<div class = 'center'><p>This is a break.</p>\
  <p>Press the space bar to continue.</p>"],
  choices: [32],
  timing_post_trial: 1600
}

/* Make sure participants are behaving */
var behave = {
    type: "html-keyboard-response",
    timeline: [{
      stimulus: "<div class = 'center'><p>It seems that you have pressed the wrong \
  key many times recently.</p>\
  <p>Please perform the task as accurately and as quickly as you can.</p>\
  <p>Press the space bar to continue.</p>"
    }],
    choices: [32],
    conditional_function: function() {
      var trialType = jsPsych.currentTrial().type,
        trialN = jsPsych.data.get().filter({
          trial_type: "bRMS"
        }).count();

      if (trialType == 'bRMS' && // This isn't a break
        jsPsych.currentTrial().data.trial > lastWarned + experiment_performance_trials && // unwarned
        ((trialN >= experiment_performance_trials && // sufficient acc data
            jsPsych.data.get().filter({
              trial_type: "bRMS"
            }).last(experiment_performance_trials).select('acc').mean() < experiment_performance_thresh) || // performance bad
          (trialN >= experiment_RT_trials && // sufficient rt data
            jsPsych.data.get().filter({
              trial_type: "bRMS"
            }).last(experiment_RT_trials).filterCustom(function(x) {
              return x.rt < experiment_RT_threshold
            }).count() >= experiment_RT_trial_threshold))) { // enough fast trials
        lastWarned = jsPsych.currentTrial().data.trial;
        //console.log("condition is true");
        return true;
      } else {
        //console.log("condition is false");
        return false;
      }
    }
  },
  lastWarned = -experiment_performance_trials;

for (ii = breakEvery; ii < stimuli.length; ii += (breakEvery + 1)) {
  stimuli.splice(ii, 0, breakMsg);
};


for (ii = 1; ii < (stimuli.length - 1); ii += 2) {
  stimuli.splice(ii, 0, behave);
}


/* define block */
var bRMS_block = {
  timeline: stimuli,
  visUnit: function() {
    return unitSize
  },
  on_finish: function() {
    var d = new Date();
    if ((d.getTime() - exp_start_time) > time_limit) {
      jsPsych.endCurrentTimeline();
    }
  }
};


//** Animation test ** //
var test_animation = {
    type: 'bRMS-test',
    timeline: [{
        stimulus: all_images[1],
        prompt: "<p>Testing for the \
      compatibility of your personal computer with this HIT.</p> \
      <p>This will take approximately 15 seconds more.</p>"
      },
      {
        stimulus: all_images[2],
        prompt: "<p>Testing for the \
      compatibility of your personal computer with this HIT.</p> \
      <p>This will take approximately 10 seconds more.</p>"
      },
      {
        stimulus: all_images[3],
        prompt: "<p>Testing for the \
      compatibility of your personal computer with this HIT.</p> \
      <p>This will take approximately 5 seconds more.</p>"
      }
    ],
    data: {
      timing_response: 4,
      stimulus_alpha: stimAlphas,
      timing_post_trial: 100,
      within_ITI: ITI - 100,
      fade_in_time: fade_in_time,
      fade_out_time: fade_out_time,
      fade_out_length: fade_out_length
    },
    stimulus_alpha: stimAlphas,
    timing_post_trial: 100,
    within_ITI: ITI - 100,
    timing_response: 4,
    fade_in_time: fade_in_time,
    fade_out_time: fade_out_time,
    fade_out_length: fade_out_length,
    visUnit: 4,
    choices: ["none"]
  },
  poor_animation = {
    type: 'html-keyboard-response',
    conditional_function: function() {
      if (jsPsych.data.get().last(3).select('sProblem').sum() > sProblemCrit ||
        jsPsych.data.get().last(3).select('bProblem').sum() > bProblemCrit) {
        return true;
      } else {
        return false;
      }
    },
    timeline: [{
      stimulus: "<div class = 'center'>\
<p>It seems that the animation is not presented correctly on your computer.</p>\
<p>This may be due to old hardware, or too many open applications.</p>\
<p><b>Please return this HIT</b>.</p>\
<p>We'll be glad to see you participating in future HITs.</p>\
<p>For any questions, please email \
yaniv.abir+mturk@mail.huji.ac.il</p>\
<p>Press the space bar to continue.</p></div>"
    }],
    choices: [32],
    //** needed eventualy **//
    on_finish: function() {
      psiturk.saveData({
        success: function() {
          jsPsych.endExperiment('The experiment has been aborted. <b>Please return HIT.</b>');
        }
      });
    }
  }


//** 7---------Debrief **//

var debrief = [{
    type: "html-keyboard-response",
    stimulus: "<div class='center'>You have completed this part of the study.\
    <p>You will now answer several questions. Please answer them sincerely, \
    we remind you that your answers are completely annonymous.</p>\
    <p align='center'><i>Press the space bar to continue.</i></p></div>",
    choices: [32]
  },
  {
    type: "survey-text",
    questions: [{
        prompt: "How old are you?",
        columns: 20,
        rows: 1,
        value: ''
      },
      {
        prompt: 'Have you been diagnosed with, or believe you have an attention deficit disorder?',
        columns: 60,
        rows: 1,
        value: ''
      }
    ]
  }, {
    type: "survey-multi-choice",
    questions: [{
        prompt: "What is your gender?",
        options: ["Male", "Female", "Other"],
        required: true
      },
      {
        prompt: "What is your dominant hand?",
        options: ["Right", "Left", "Both"],
        required: true
      },
      {
        prompt: "Is English your native language?",
        options: ["Yes", "No"],
        required: true
      }
    ]
  },
  {
    type: 'survey-likert',
    questions: [{
      prompt: "How fluent are you in reading and understanding English?",
      labels: ["1<br>Not at all", "2", "3", "4", "5<br>Very fluent"],
      required: true
    }]
  },
  {
    type: 'survey-text',
    questions: [{
      prompt: "Did you have any special strategy that helped you seeing \
    the faces more quickly?",
      columns: 100,
      rows: 4,
      value: ''
    }],
  },
  {
    type: 'survey-multi-choice',
    questions: [{
        prompt: "Do you consider yourself to be:",
        options: ["Heterosexual or straight", "Gay or lesbian", "Bisexual", "Other"],
        required: false
      },
      {
        prompt: "People are different in their sexual attraction to other people.\
  Which best describes your feelings?",
        options: ["Only attracted to females", "Mostly attracted to females",
          "Equally attracted to females and males", "Mostly attracted to males", "Only attracted to males", "Not sure"
        ],
        required: false
      }
    ]
  },
  {
    type: "html-keyboard-response",
    stimulus: "<div class='center'><p>You will now be presented with a few more statements.\
	Please read each statement carfully, and indicate the degree to which you agree or disagree with it.</p>\
    <p>We remind you that your answers are completely annonymous.</p>\
    <p align='center'><i>Press the space bar to continue.</i></p></div>",
    choices: [32]
  }
].concat(jsPsych.randomization.shuffle(
  [{
      type: 'survey-likert',
      questions: [{
        prompt: "Laws designed to protect the environment pose too high a cost on businesses that contribute to the economy.",
        labels: ["1<br>Completely Disagree", "2", "3", "4", "5", "6", "7<br>Completely Agree"],
        required: true
      }],
      data: {
        question: 'Environment laws',
        reverse: false
      }
    },
    {
      type: 'survey-likert',
      questions: [{
        prompt: "A woman should have the right to choose what to do with her body, even if that means getting an abortion.", //*reverse scored
        labels: ["1<br>Completely Disagree", "2", "3", "4", "5", "6", "7<br>Completely Agree"],
        required: true
      }],
      data: {
        question: 'Abortion',
        reverse: true
      }
    },
    {
      type: 'survey-likert',
      questions: [{
        prompt: "The United States should not have invaded Iraq.", //*reverse scored
        labels: ["1<br>Completely Disagree", "2", "3", "4", "5", "6", "7<br>Completely Agree"],
        required: true
      }],
      data: {
        question: 'Iraq',
        reverse: true
      }
    },
    {
      type: 'survey-likert',
      questions: [{
        prompt: "Homosexuals should have the same right to marriage as anyone else.", //*reverse scored
        labels: ["1<br>Completely Disagree", "2", "3", "4", "5", "6", "7<br>Completely Agree"],
        required: true
      }],
      data: {
        question: 'Homosexuals',
        reverse: true
      }
    },
    {
      type: 'survey-likert',
      questions: [{
        prompt: "Affirmative action gives those groups with a history of oppression a chance to get ahead.", //*reverse scored
        labels: ["1<br>Completely Disagree", "2", "3", "4", "5", "6", "7<br>Completely Agree"],
        required: true
      }],
      data: {
        question: 'Affirmative action',
        reverse: true
      }
    },
    {
      type: 'survey-likert',
      questions: [{
        prompt: "Gun control laws are not nearly strict enough.", //*reverse scored
        labels: ["1<br>Completely Disagree", "2", "3", "4", "5", "6", "7<br>Completely Agree"],
        required: true
      }],
      data: {
        question: 'Gun control',
        reverse: true
      }
    },
    {
      type: 'survey-likert',
      questions: [{
        prompt: "It is important for our legal system to use the death penalty as punishment for heinous crimes. ",
        labels: ["1<br>Completely Disagree", "2", "3", "4", "5", "6", "7<br>Completely Agree"],
        required: true}],
        data: {
          question: 'Death penalty',
          reverse: false
        }
    },
    {
      type: 'survey-likert',
      questions: [{
        prompt: "Stem Cell research has important implications for medical advances, and should be pursued at all costs.", //*reverse scored
        labels: ["1<br>Completely Disagree", "2", "3", "4", "5", "6", "7<br>Completely Agree"],
        required: true}],
        data: {
          question: 'Stem Cell',
          reverse: true
        }
    }
  ])).concat([{
    type: "survey-multi-choice",
    questions: [{
      prompt: "Do you have a driver’s license?",
      options: ["Yes", "No"],
      required: true
    }]
  },
  {
    conditional_function: function() {
      if (JSON.parse(jsPsych.data.get().last(1).select('responses').values).Q0 == 'Yes') {
        return true;
      } else {
        return false;
      }
    },
    timeline: [{
        type: 'survey-likert',
        questions: [{
          prompt: "Compared to the average driver, how would you rate your own driving?", //*reverse scored
          labels: ["1<br>Much worse than average", "2", "3", "4", "5", "6", "7<br>Much better than average"],
          required: true
        }]
      },
      {
        type: "survey-text",
        questions: [{
          prompt: "In your best estimate, how many accidents were you involved in during the last three years as a driver, including minor accidents with no injuries or damage? (If none, mark 0)",
          columns: 20,
          rows: 1,
          value: ''
        }],
      }
    ],
  },
  {
    type: "survey-text",
    questions: [{
      prompt: 'In your best estimate, how many accidents were you involved in during the last three years as a pedestrian,\
		including minor accidents with no injuries or damage? (If none, mark 0)',
      columns: 60,
      rows: 1,
      value: ''
    }]
  },
  {
    type: "html-keyboard-response",
    stimulus: '<div class="center">Thank you for participating in this study!<p>\
    In this study we were interested in examining reaction-times and \
    precision in a dynamic environment.</p>\
    <p>Once you press the space bar, your results will be uploaded to the \
    server, and the HIT will complete. <b>This may take several minutes - do not \
    refresh or close your browser during this time.</b></p>\
    <p>Press the space bar to complete this HIT.</p></div>',
    choices: [32]
  }
]);


// Put it all together
var experiment_blocks = [];
experiment_blocks.push(test_animation);
experiment_blocks.push(poor_animation);
experiment_blocks.push(fullscreen);
experiment_blocks.push(preCalibIns)
experiment_blocks.push(makeSureLoop);
experiment_blocks.push(instructions);
experiment_blocks.push(secChanceLoop);
experiment_blocks.push(mainBlockIns);
experiment_blocks.push(bRMS_block);
experiment_blocks = experiment_blocks.concat(debrief);

// Save data to file functions
// var textFile = null,
//   makeTextFile = function(text) {
//     var data = new Blob([text], {
//       type: 'text/plain'
//     });
//
//     // If we are replacing a previously generated file we need to
//     // manually revoke the object URL to avoid memory leaks.
//     if (textFile !== null) {
//       window.URL.revokeObjectURL(textFile);
//     }
//
//     textFile = window.URL.createObjectURL(data);
//
//     // returns a URL you can use as a href
//     return textFile;
//   };
//
// var saveData = function(data, filename) {
//   var link = document.createElement('a');
//   link.setAttribute('download', filename);
//   link.href = makeTextFile(data);
//   document.body.appendChild(link);
//
//   // wait for the link to be added to the document
//   window.requestAnimationFrame(function() {
//     var event = new MouseEvent('click');
//     link.dispatchEvent(event);
//     document.body.removeChild(link);
//   });
// }


// Initiate experiment
var exp_start_time = 0;
var d = new Date();
jsPsych.init({
  timeline: experiment_blocks,
  fullscreen: true,
  // on_finish: function(data) {
    // psiturk.recordUnstructuredData('jsPsych_trial_data',
      // jsPsych.data.get().json());
    // psiturk.recordUnstructuredData('jsPsych_event_data',
      // jsPsych.data.getInteractionData().json());
    // psiturk.saveData({
      // success: function() {
        // psiturk.completeHIT();
      // }
    // })
  // },
  // on_data_update: function(data) {
  //  psiturk.recordTrialData(data);
  // },
  preload_images: images,
   on_trial_start: function() {
     // Record start time of bRMS block
     if (exp_start_time == 0 && jsPsych.currentTrial().type == 'bRMS') {
       exp_start_time = d.getTime();
      // psiturk.finishInstructions(); // advance status to 2
     }
   }
});
