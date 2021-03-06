namespace :comments do

  desc "Recalculates all the comment counters for debates and proposals"
  task count: :environment do
    Debate.all.pluck(:id).each{ |id| Debate.reset_counters(id, :comments) }
    Proposal.all.pluck(:id).each{ |id| Proposal.reset_counters(id, :comments) }
  end

end
