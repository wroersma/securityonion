# This state exists to assist in resolving https://github.com/Security-Onion-Solutions/securityonion/issues/1144
# Its job it to remove the old highstate schedule named 'schedule' so that we can replace it with a highstate
# schedule named 'highstate' so that we can manage the highstate schedule using the global or minion pillar.

remove_pre_2.3.1_highstate_schedule:
  schedule.absent:
    - name: schedule

highstate:
  schedule.present:
    - function: state.highstate
    - minutes: 15
    - maxrunning: 1
    - onchanges:
      - schedule: remove_pre_2.3.1_highstate_schedule