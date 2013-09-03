require 'qu'

class DocumentJob
  Dir[File.join(APP_ROOT, 'lib', 'jobs', '*_job.rb')].each { |path| require path }

  FLOW = [
    { :class => ExtractionJob,          :perc_ratio => 30 },
    { :class => LayoutAnalysisJob,      :perc_ratio => 10 },
    { :class => EntitiesRecognitionJob, :perc_ratio => 60 },
  ]

  def self.perform(id)
    Document.where(id: id).update(state: 'waiting')
    Qu.enqueue(FLOW.first[:class], id)
  end

  def self.next_job!(id)
    i = current_job_index
    if i < FLOW.size - 1
      Qu.enqueue(FLOW[i+1][:class], id)
    else
      Document.where(id: id).update(status: nil, percentage: 100, analyzed_at: Time.now)
    end
  end

  def self.current_percentage(cur, total)
    raise "total is nil or zero" if total.nil? || total.zero?
    i = current_job_index
    base_perc  = i.zero? ? 0 : FLOW[0...i].map { |job| job[:perc_ratio] }.inject(&:+)
    perc_ratio = FLOW[i][:perc_ratio]
    res = base_perc + (perc_ratio * (cur / total.to_f)).round
    res > 100 ? 100 : res
  end

  def self.current_job_index
    i = FLOW.find_index { |job| job[:class] == self }
    raise NotImplementedError,
      'Job class is missing from FLOW definition' if i.nil?
    return i
  end
end
