import Foundation
@testable import SwiftlySalesforce

extension Mocker {
    
    static let limits = """
{
  "AnalyticsExternalDataSizeMB" : {
    "Max" : 40960,
    "Remaining" : 40960
  },
  "ConcurrentAsyncGetReportInstances" : {
    "Max" : 200,
    "Remaining" : 200
  },
  "ConcurrentEinsteinDataInsightsStoryCreation" : {
    "Max" : 5,
    "Remaining" : 4
  },
  "ConcurrentEinsteinDiscoveryStoryCreation" : {
    "Max" : 2,
    "Remaining" : 2
  },
  "ConcurrentSyncReportRuns" : {
    "Max" : 20,
    "Remaining" : 20
  },
  "DailyAnalyticsDataflowJobExecutions" : {
    "Max" : 60,
    "Remaining" : 60
  },
  "DailyAnalyticsUploadedFilesSizeMB" : {
    "Max" : 51200,
    "Remaining" : 51200
  },
  "DailyApiRequests" : {
    "Max" : 15000,
    "Remaining" : 14980,
    "Ant Migration Tool" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Dataloader Bulk" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Dataloader Partner" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Force.com IDE" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Limits" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "My Test Canvas App" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Salesforce Mobile Dashboards" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Salesforce Touch" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Salesforce for Outlook" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "TEST APP" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Workbench" : {
      "Max" : 0,
      "Remaining" : 0
    }
  },
  "DailyAsyncApexExecutions" : {
    "Max" : 250000,
    "Remaining" : 250000
  },
  "DailyBulkApiRequests" : {
    "Max" : 10000,
    "Remaining" : 10000,
    "Ant Migration Tool" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Dataloader Bulk" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Dataloader Partner" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Force.com IDE" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Limits" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "My Test Canvas App" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Salesforce Mobile Dashboards" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Salesforce Touch" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Salesforce for Outlook" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "TEST APP" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Workbench" : {
      "Max" : 0,
      "Remaining" : 0
    }
  },
  "DailyBulkV2QueryFileStorageMB" : {
    "Max" : 976562,
    "Remaining" : 976562
  },
  "DailyBulkV2QueryJobs" : {
    "Max" : 10000,
    "Remaining" : 10000
  },
  "DailyDurableGenericStreamingApiEvents" : {
    "Max" : 10000,
    "Remaining" : 10000
  },
  "DailyDurableStreamingApiEvents" : {
    "Max" : 10000,
    "Remaining" : 10000
  },
  "DailyEinsteinDataInsightsStoryCreation" : {
    "Max" : 1000,
    "Remaining" : 1000
  },
  "DailyEinsteinDiscoveryPredictAPICalls" : {
    "Max" : 50000,
    "Remaining" : 50000
  },
  "DailyEinsteinDiscoveryPredictionsByCDC" : {
    "Max" : 500000,
    "Remaining" : 500000
  },
  "DailyEinsteinDiscoveryStoryCreation" : {
    "Max" : 20,
    "Remaining" : 20
  },
  "DailyGenericStreamingApiEvents" : {
    "Max" : 10000,
    "Remaining" : 10000,
    "Ant Migration Tool" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Dataloader Bulk" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Dataloader Partner" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Force.com IDE" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Limits" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "My Test Canvas App" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Salesforce Mobile Dashboards" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Salesforce Touch" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Salesforce for Outlook" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "TEST APP" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Workbench" : {
      "Max" : 0,
      "Remaining" : 0
    }
  },
  "DailyStandardVolumePlatformEvents" : {
    "Max" : 10000,
    "Remaining" : 10000
  },
  "DailyStreamingApiEvents" : {
    "Max" : 10000,
    "Remaining" : 10000,
    "Ant Migration Tool" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Dataloader Bulk" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Dataloader Partner" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Force.com IDE" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Limits" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "My Test Canvas App" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Salesforce Mobile Dashboards" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Salesforce Touch" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Salesforce for Outlook" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "TEST APP" : {
      "Max" : 0,
      "Remaining" : 0
    },
    "Workbench" : {
      "Max" : 0,
      "Remaining" : 0
    }
  },
  "DailyWorkflowEmails" : {
    "Max" : 195,
    "Remaining" : 195
  },
  "DataStorageMB" : {
    "Max" : 5,
    "Remaining" : 3
  },
  "DurableStreamingApiConcurrentClients" : {
    "Max" : 20,
    "Remaining" : 20
  },
  "FileStorageMB" : {
    "Max" : 20,
    "Remaining" : 20
  },
  "HourlyAsyncReportRuns" : {
    "Max" : 1200,
    "Remaining" : 1200
  },
  "HourlyDashboardRefreshes" : {
    "Max" : 200,
    "Remaining" : 200
  },
  "HourlyDashboardResults" : {
    "Max" : 5000,
    "Remaining" : 5000
  },
  "HourlyDashboardStatuses" : {
    "Max" : 999999999,
    "Remaining" : 999999999
  },
  "HourlyLongTermIdMapping" : {
    "Max" : 100000,
    "Remaining" : 100000
  },
  "HourlyODataCallout" : {
    "Max" : 1000,
    "Remaining" : 1000
  },
  "HourlyPublishedPlatformEvents" : {
    "Max" : 50000,
    "Remaining" : 50000
  },
  "HourlyPublishedStandardVolumePlatformEvents" : {
    "Max" : 1000,
    "Remaining" : 1000
  },
  "HourlyShortTermIdMapping" : {
    "Max" : 100000,
    "Remaining" : 100000
  },
  "HourlySyncReportRuns" : {
    "Max" : 500,
    "Remaining" : 500
  },
  "HourlyTimeBasedWorkflow" : {
    "Max" : 50,
    "Remaining" : 50
  },
  "MassEmail" : {
    "Max" : 10,
    "Remaining" : 10
  },
  "MonthlyEinsteinDiscoveryStoryCreation" : {
    "Max" : 500,
    "Remaining" : 500
  },
  "MonthlyPlatformEvents" : {
    "Max" : 300000,
    "Remaining" : 300000
  },
  "Package2VersionCreates" : {
    "Max" : 6,
    "Remaining" : 6
  },
  "PermissionSets" : {
    "Max" : 1500,
    "Remaining" : 1492,
    "CreateCustom" : {
      "Max" : 1000,
      "Remaining" : 992
    }
  },
  "SingleEmail" : {
    "Max" : 15,
    "Remaining" : 15
  },
  "StreamingApiConcurrentClients" : {
    "Max" : 20,
    "Remaining" : 20
  }
}
"""
}
