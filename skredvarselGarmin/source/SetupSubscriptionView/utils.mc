using Toybox.WatchUi as Ui;

function setHasSubscriptionAndSwitchToInitialView() {
  $.setHasSubscription(true);
  $.switchToInitialView(Ui.SLIDE_BLINK);
}

function switchToInactiveSubscriptionView() {
  Ui.switchToView(new InactiveSubscriptionView(), null, Ui.SLIDE_BLINK);
}

function switchedToFailedSubscriptionSetupView() {
  Ui.switchToView(
    new TextAreaView(
      $.getOrLoadResourceString(
        "Fikk ikke til å sette opp abonnement. Avslutt appen og prøv på nytt.",
        :FailedToSetupSubscription
      )
    ),
    new TextAreaViewDelegate(),
    Ui.SLIDE_BLINK
  );
}
