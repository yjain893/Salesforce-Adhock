# Salesforce Metadata Deployment Guide

## Project Structure

Your Salesforce project now has the proper structure for metadata deployment:

```
├── sfdx-project.json          # SFDX project configuration
├── manifest/
│   └── package.xml            # Metadata deployment manifest
└── force-app/
    └── main/
        └── default/
            ├── classes/       # Apex Classes
            ├── triggers/      # Apex Triggers  
            ├── objects/       # Custom Objects
            ├── staticresources/ # Static Resources
            ├── flows/         # Flows
            └── lwc/           # Lightning Web Components

```

## Common Deployment Commands

### 1. Deploy using package.xml
```bash
sfdx force:source:deploy -x manifest/package.xml -u yourOrgAlias
```

### 2. Deploy specific metadata types
```bash
sfdx force:source:deploy -m "ApexClass,CustomObject" -u yourOrgAlias
```

### 3. Deploy all source
```bash
sfdx force:source:deploy -p force-app -u yourOrgAlias
```

### 4. Validate deployment (check only)
```bash
sfdx force:source:deploy -x manifest/package.xml -u yourOrgAlias --checkonly
```

## Troubleshooting "package.xml not found" Error

If you get this error, ensure:

1. ✅ The `manifest/package.xml` file exists (now created)
2. ✅ You're running the command from the project root directory
3. ✅ The file path in your command is correct (`-x manifest/package.xml`)
4. ✅ Your org is properly authenticated (`sfdx force:auth:list`)

## Authentication Setup

If you haven't authenticated with your Salesforce org yet:

```bash
# For production/developer org
sfdx force:auth:web:login -a myOrgAlias

# For sandbox
sfdx force:auth:web:login -a mySandboxAlias -r https://test.salesforce.com
```

## Next Steps

1. Place your metadata files in the appropriate `force-app/main/default/` subdirectories
2. Update `manifest/package.xml` to include only the metadata types you want to deploy
3. Authenticate with your target Salesforce org
4. Run your deployment command

The package.xml file is now properly configured and should resolve your deployment error!